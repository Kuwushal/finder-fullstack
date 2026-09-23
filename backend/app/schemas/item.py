from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class ItemCreate(BaseModel):
    name: str
    location: str
    description: Optional[str] = None
    tags: Optional[List[str]] = []

class ItemUpdate(BaseModel):
    locaiton: Optional[str] = None
    description: Optional[str] = None
    tags: Optional[List[str]] = None

class ItemResponse(BaseModel):
    id: int
    name: str
    location: str
    description: Optional[str] = None
    tags: List[str] = []
    location_history: List[str] = []
    created_at: datetime
    updated_at: Optional[datetime] = None

    model_config = {
        "from_attributes": True,
    }
    