from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import items, ai

app = FastAPI(title="Finder")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(items.router)
app.include_router(ai.router)

@app.get("/")
def root():
    return {"message": "Finder is running!"}
