from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel, ConfigDict
from typing import List, Optional
from datetime import datetime, timezone
from src.models.models import User, Meditation, ActivationCode, get_db

router = APIRouter(prefix="/api/users", tags=["users"])

# ---------- Pydantic схемы ----------

class ActivationInfo(BaseModel):
    code: str
    activated_at: Optional[datetime]
    expires_at: Optional[datetime]
    duration_days: Optional[int]
    is_used: bool

    model_config = ConfigDict(from_attributes=True)


class UserSchema(BaseModel):
    id: str
    name: str
    is_premium: bool = False
    premium_expires_at: Optional[datetime] = None
    last_played_meditation_id: Optional[int] = None

    model_config = ConfigDict(from_attributes=True)


class UserCreate(BaseModel):
    id: str
    name: Optional[str] = "User"


class UserUpdate(BaseModel):
    name: str


class UserResponse(BaseModel):
    id: str
    name: str
    is_premium: bool
    premium_expires_at: Optional[str]
    last_played_meditation_id: Optional[int]


# ---------- Эндпоинты ----------

# GET /api/users
@router.get("/", response_model=List[UserSchema])
def get_users(db: Session = Depends(get_db)):
    return db.query(User).all()


# GET /api/users/{id}
@router.get("/{user_id}", response_model=UserResponse)
def get_user(user_id: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return {
        "id": user.id,
        "name": user.name,
        "is_premium": user.has_active_premium(),
        "premium_expires_at": user.premium_expires_at.isoformat() if user.premium_expires_at else None,
        "last_played_meditation_id": user.last_played_meditation_id,
    }


# POST /api/users
@router.post("/", response_model=UserSchema)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.id == user.id).first()
    if existing:
        raise HTTPException(status_code=400, detail="User already exists")

    new_user = User(id=user.id, name=user.name)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


# PUT /api/users/{id}
@router.put("/{user_id}", response_model=UserSchema)
def update_user(user_id: str, user_update: UserUpdate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.name = user_update.name
    db.commit()
    db.refresh(user)
    return user


# DELETE /api/users/{id}
@router.delete("/{user_id}", status_code=204)
def delete_user(user_id: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    db.delete(user)
    db.commit()
    return None


# POST /api/users/{user_id}/last_played/{meditation_id}
@router.post("/{user_id}/last_played/{meditation_id}")
def update_last_played(user_id: str, meditation_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    meditation = db.query(Meditation).filter(Meditation.id == meditation_id).first()
    if not meditation:
        raise HTTPException(status_code=404, detail="Meditation not found")

    user.last_played_meditation_id = meditation_id
    db.commit()
    db.refresh(user)
    return {"message": "Last played meditation updated", "last_played_meditation_id": meditation_id}


# GET /api/users/{user_id}/last_played
@router.get("/{user_id}/last_played")
def get_last_played(user_id: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if not user.last_played_meditation_id:
        return None

    meditation = db.query(Meditation).filter(Meditation.id == user.last_played_meditation_id).first()
    if not meditation:
        return None

    return {
        "id": meditation.id,
        "title": meditation.title,
        "description": meditation.description,
        "duration_seconds": meditation.duration_seconds,
        "audio_url": meditation.audio_url,
        "is_premium": meditation.is_premium,
        "category": meditation.category,
    }


# GET /api/users/{user_id}/subscriptions
@router.get("/{user_id}/subscriptions", response_model=List[ActivationInfo])
def get_user_subscriptions(user_id: str, db: Session = Depends(get_db)):
    """Возвращает историю активаций (ActivationCode) для пользователя."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    codes = (
        db.query(ActivationCode)
        .filter(ActivationCode.user_id == user_id)
        .order_by(ActivationCode.activated_at.desc())
        .all()
    )

    if not codes:
        raise HTTPException(status_code=404, detail="No activation history")

    return codes
