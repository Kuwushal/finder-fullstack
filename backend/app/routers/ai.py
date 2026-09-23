from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.database import get_db
from app.models.item import Item
from app.services.ollama import parse_message

router = APIRouter(prefix="/ai", tags=["ai"])

class MessageInput(BaseModel):
    message: str

@router.post("/chat")
def chat(input: MessageInput, db: Session = Depends(get_db)):
    parsed = parse_message(input.message)
    action = parsed.get("action")

    if action == "save":
        name = parsed["item"].lower()
        location = parsed["location"]
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
        name = parsed["item"].lower()
        item = db.query(Item).filter(Item.name == name).first()
        if not item:
            raise HTTPException(status_code=404, detail=f"No record found for {name}")
        return {"message": f"Your {name} is in {item.location}"}

    raise HTTPException(status_code=400, detail="Could not understand the message")
