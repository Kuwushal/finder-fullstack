#!/bin/bash
set -euo pipefail

check_deps() {
    if ! command -v git &>/dev/null; then
        echo "Error: git is not installed"
        exit 1
    fi

    if ! command -v gh &>/dev/null; then
        echo "Error: GitHub CLI is not installed. Run: brew install gh"
        exit 1
    fi

    if ! gh auth status &>/dev/null; then
        echo "Error: not authenticated. Run: gh auth login"
        exit 1
    fi
}

usage() {
    echo "Usage: g <command> [args]"
    echo ""
    echo "Commands:"
    echo "  new <name>        Create a new project + GitHub repo"
    echo "  init              Initialise current folder as a GitHub repo"
    echo "  push              Push latest changes"
    echo "  save <message>    Add, commit and push"
    echo "  status            Show git status"
    echo "  branch <name>     Create a new branch"
    echo "  switch <name>     Switch to a branch"
    echo "  clone <user/repo> Clone a GitHub repo"
    echo "  open              Open repo in browser"
    exit 1
}

ask_visibility() {
    echo "Visibility:" >&2
    echo "1) Private" >&2
    echo "2) Public" >&2
    read -p "Choose [1/2]: " choice

    case "$choice" in
        1|private|Private) echo "private" ;;
        2|public|Public)   echo "public" ;;
        *) echo "Invalid choice. Enter 1 or 2" >&2; exit 1 ;;
    esac
}

cmd_new() {
    local name="${1:-}"

    if [[ -z "$name" ]]; then
        echo "Error: provide a project name. Usage: g new <name>"
        exit 1
    fi

    mkdir "$name"
    cd "$name"

    local visibility
    visibility=$(ask_visibility)

    git init
    git checkout -b main
    gh repo create "$name" --"$visibility" --source=. --remote=origin
    echo "# $name" > README.md
    git add .
    git commit -m "Initial commit"
    git push -u origin main

    echo "Done! $name created and pushed to GitHub."
}

cmd_init() {
    local name
    name=$(basename "$PWD")
    local default_commit="project repo initialisation"

    echo
    echo "Repository: $name"
    echo

    local visibility
    visibility=$(ask_visibility)
    read -rp "Description []: " description
    read -rp "Initial commit message [$default_commit]: " commit_msg
    commit_msg="${commit_msg:-$default_commit}"

    echo
    echo "=== PLAN ==="
    echo "Repository:  $name"
    echo "Visibility:  $visibility"
    echo "Description: ${description:-<none>}"
    echo "Commit msg:  $commit_msg"
    echo "GitHub:      create $visibility repository and push"
    echo "========"
    echo

    read -rp "Proceed? [Y/n]: " proceed
    proceed="${proceed:-Y}"

    if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi

    if [[ ! -d ".git" ]]; then
        git init
        git branch -M main
    fi

    if [[ ! -f "README.md" ]]; then
        echo "# $name" > README.md
    fi

    git add .

    if git diff --cached --quiet; then
        echo "Nothing to commit"
    else
        git commit -m "$commit_msg"
    fi

    if git remote get-url origin >/dev/null 2>&1; then
        echo "Remote origin already exists"
    else
        if gh repo view "$name" >/dev/null 2>&1; then
            read -rp "GitHub repo '$name' already exists. Use it as origin? [Y/n]: " use_existing
            use_existing="${use_existing:-Y}"
            if [[ "$use_existing" =~ ^[Yy]$ ]]; then
                git remote add origin "https://github.com/$(gh api user --jq .login)/$name.git"
            else
                echo "Aborted."
                exit 0
            fi
        else
            if [ -n "$description" ]; then
                gh repo create "$name" --"$visibility" --description "$description" --source=. --remote=origin
            else
                gh repo create "$name" --"$visibility" --source=. --remote=origin
            fi
        fi
    fi

    git push -u origin main

    echo
    echo "✓ Done."
}

cmd_push() {
    git push
}

cmd_save() {
    local message="${1:-}"

    if [[ -z "$message" ]]; then
        echo "Error: provide a commit message. Usage: g save \"message\""
        exit 1
    fi

    git add .
    git commit -m "$message"
    git push
}

cmd_status() {
    git status
}

cmd_branch() {
    local name="${1:-}"

    if [[ -z "$name" ]]; then
        echo "Error: provide a branch name. Usage: g branch <name>"
        exit 1
    fi

    git checkout -b "$name"
}

cmd_switch() {
    local name="${1:-}"

    if [[ -z "$name" ]]; then
        echo "Error: provide a branch name. Usage: g switch <name>"
        exit 1
    fi

    git checkout "$name"
}

cmd_clone() {
    local repo="${1:-}"

    if [[ -z "$repo" ]]; then
        echo "Error: provide a repo. Usage: g clone USER/REPO"
        exit 1
    fi

    gh repo clone "$repo"
}

cmd_open() {
    gh repo view --web
}

# --- run ---

check_deps

COMMAND="${1:-}"
[[ -n "$COMMAND" ]] && shift

case "$COMMAND" in
    new)    cmd_new "$@" ;;
    init)   cmd_init ;;
    push)   cmd_push ;;
    save)   cmd_save "$@" ;;
    status) cmd_status ;;
    branch) cmd_branch "$@" ;;
    switch) cmd_switch "$@" ;;
    clone)  cmd_clone "$@" ;;
    open)   cmd_open ;;
    *)      usage ;;
esac