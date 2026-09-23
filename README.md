# Finder

An AI-powered app that remembers where you put things. Talk to it naturally — it understands and remembers.

> "I put my keys in the desk drawer."  
> "Where are my keys?"  
> "Your keys are in the desk drawer."

## Tech Stack

- **Backend:** Python, FastAPI, PostgreSQL, SQLAlchemy, Alembic
- **AI:** Ollama (llama3) running locally
- **Frontend:** React + Vite (coming soon)

## Requirements

- Python 3.10+
- PostgreSQL
- [Ollama](https://ollama.com) with llama3 pulled (`ollama pull llama3`)

## Setup

```bash
git clone https://github.com/<your-username>/finder.git
cd finder/backend

python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

createdb finder_db
cp .env.example .env

alembic upgrade head

PYTHONPATH=. uvicorn app.main:app --reload
```

Open `http://localhost:8000/docs` to explore the API.

## How it works

```
User message → FastAPI → Ollama (llama3) → structured JSON → PostgreSQL
```

The LLM only interprets language. The database is the source of truth.

## API

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /ai/chat | Send a natural language message |
| GET | /items | Get all stored items |
| GET | /items/{id} | Get a single item |
| PUT | /items/{id} | Update an item |
| DELETE | /items/{id} | Delete an item |

## Example

```json
POST /ai/chat
{ "message": "I put my passport in the blue folder on the top shelf" }

→ { "message": "Saved: passport → blue folder on the top shelf" }
```

```json
POST /ai/chat
{ "message": "Where is my passport?" }

→ { "message": "Your passport is in blue folder on the top shelf" }
```
