from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.database import get_db
from app.models.item import Item
from app.services.ollama import parse_message

router = APIRouter(prefix="/ai", tags=["ai"])

NON_ITEM_PHRASES = [
    "going to", "have to be", "need to be", "i am going", "i'm going",
    "meeting", "appointment", "remind me", "tomorrow", "today", "tonight",
    "call", "visit", "pick up", "drop off", "schedule",
    "i need", "i want", "i should", "i must", "i will", "i'll"
]

ONLY_TRACKS = "I only track physical items and where you put them."

class MessageInput(BaseModel):
    message: str

def is_non_item_message(message: str) -> bool:
    lower = message.lower()
    return any(phrase in lower for phrase in NON_ITEM_PHRASES)

@router.post("/chat")
def chat(input: MessageInput, db: Session = Depends(get_db)):
    if is_non_item_message(input.message):
        return {"message": ONLY_TRACKS}

    parsed = parse_message(input.message)
    action = parsed.get("action")

    if action == "save":
        name = parsed.get("item", "").lower().strip()
        location = parsed.get("location", "").strip()
        if not name or not location:
            return {"message": ONLY_TRACKS}
        item = db.query(Item).filter(Item.name == name).first()
        if item:
            history = item.location_history or []
            history.append(item.location)
            item.location_history = history
            item.location = location
            db.commit()
            return {"message": f"Updated: {name} is now in {location}"}
        else:
            db.add(Item(name=name, location=location))
            db.commit()
            return {"message": f"Saved: {name} → {location}"}

    elif action == "find":
        name = parsed.get("item", "").lower().strip()
        if not name:
            return {"message": ONLY_TRACKS}
        item = db.query(Item).filter(Item.name == name).first()
        if not item:
            raise HTTPException(status_code=404, detail=f"No record found for {name}")
        return {"message": f"Your {name} is in {item.location}"}

    elif action == "none":
        return {"message": parsed.get("message", ONLY_TRACKS)}

    return {"message": ONLY_TRACKS}
