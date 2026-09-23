from fastapi import FastAPI
from app.routers import items, ai


app = FastAPI(title="Finder")

app.include_router(items.router)
app.include_router(ai.router)

@app.get("/")
def root():
    return {"message": "Finder is running!"}