from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timezone
from src.models.models import Meditation, User, get_db
from pydantic import BaseModel, ConfigDict

router = APIRouter()


class MeditationSchema(BaseModel):
    id: int
    title: str
    description: str
    duration_seconds: int
    audio_url: str
    is_premium: bool
    category: str
    last_played: bool = False

    model_config = ConfigDict(from_attributes=True)


@router.post("/seed", status_code=201)
def seed_meditations(db: Session = Depends(get_db)):
    if db.query(Meditation).count() > 0:
        raise HTTPException(status_code=400, detail="Meditation data already exists.")

    sample_data = [
        {"title": "Расслабляющий вечер", "description": "Для снятия стресса", "duration_seconds": 300, "audio_url": "url1", "is_premium": False, "category": "Снятие стресса"},
        {"title": "Фокус и концентрация", "description": "Для работы и учебы", "duration_seconds": 400, "audio_url": "url2", "is_premium": False, "category": "Фокус"},
        {"title": "Глубокий сон", "description": "Помогает уснуть", "duration_seconds": 500, "audio_url": "url3", "is_premium": True, "category": "Сон"},
        {"title": "Энергия и бодрость", "description": "Заряд на день", "duration_seconds": 350, "audio_url": "url4", "is_premium": True, "category": "Энергия"},
        {"title": "Медитация для дыхания", "description": "Успокаивает", "duration_seconds": 200, "audio_url": "url5", "is_premium": False, "category": "Снятие стресса"},
        {"title": "Вечерняя релаксация", "description": "Подготовка ко сну", "duration_seconds": 450, "audio_url": "url6", "is_premium": False, "category": "Сон"},
    ]

    for med in sample_data:
        db.add(Meditation(**med))
    db.commit()
    return {"message": "Meditation data seeded successfully"}


@router.get("/", response_model=List[MeditationSchema])
def get_meditations(user_id: Optional[str] = None, category: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Meditation)
    if category:
        query = query.filter(Meditation.category == category)
    meditations = query.all()

    is_premium_user = False
    last_played_id = None

    if user_id:
        user = db.query(User).filter(User.id == user_id).first()
        if user:
            now_utc = datetime.now(timezone.utc)
            if user.premium_expires_at:
                premium_dt = user.premium_expires_at
                if premium_dt.tzinfo is None:
                    premium_dt = premium_dt.replace(tzinfo=timezone.utc)
                is_premium_user = user.is_premium and premium_dt > now_utc
            last_played_id = user.last_played_meditation_id

    result = []
    for med in meditations:
        if med.is_premium and not is_premium_user:
            continue
        result.append(MeditationSchema(**med.__dict__, last_played=(med.id == last_played_id)))

    return result


@router.get("/{meditation_id}", response_model=MeditationSchema)
def get_meditation(meditation_id: int, user_id: Optional[str] = None, db: Session = Depends(get_db)):
    meditation = db.query(Meditation).filter(Meditation.id == meditation_id).first()
    if not meditation:
        raise HTTPException(status_code=404, detail="Meditation not found")

    is_premium_user = False
    last_played = False

    if user_id:
        user = db.query(User).filter(User.id == user_id).first()
        if user:
            now_utc = datetime.now(timezone.utc)
            if user.premium_expires_at:
                premium_dt = user.premium_expires_at
                if premium_dt.tzinfo is None:
                    premium_dt = premium_dt.replace(tzinfo=timezone.utc)
                is_premium_user = user.is_premium and premium_dt > now_utc
            last_played = (user.last_played_meditation_id == meditation_id)

    if meditation.is_premium and not is_premium_user:
        raise HTTPException(status_code=403, detail="Premium meditation. Upgrade required.")

    return MeditationSchema(**meditation.__dict__, last_played=last_played)
