# Remember

An AI-powered app that remembers where you put things.

> "I put my keys in the desk drawer."  
> "Where are my keys?"  
> "Your keys are in the desk drawer."

## Stack

- Python, FastAPI, PostgreSQL
- Local LLM via Ollama
- React + Vite

## Setup

```bash
# backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
alembic upgrade head
PYTHONPATH=. uvicorn app.main:app --reload

# frontend
cd frontend
npm install
npm run dev
```

Requires PostgreSQL and [Ollama](https://ollama.com) running locally.
