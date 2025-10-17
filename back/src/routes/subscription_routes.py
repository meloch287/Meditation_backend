from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime, timedelta, timezone
from src.models.models import User, ActivationCode, get_db
from pydantic import BaseModel
import hashlib
import uuid
from typing import List, Optional

router = APIRouter()

# ---------- Pydantic ----------
class ActivationCodeCheckResponse(BaseModel):
    status: str
    expires_in: Optional[str] = None

class ActivationCodeActivateRequest(BaseModel):
    code: str
    user_id: str

class ActivationCodeActivateResponse(BaseModel):
    status: str
    until: Optional[datetime] = None

class ActivationCodeHistoryResponse(BaseModel):
    code: str
    activated_at: Optional[datetime]
    duration_days: Optional[int]
    is_used: bool

# ---------- Helper ----------
def hash_code(code: str) -> str:
    return hashlib.sha256(code.encode()).hexdigest()

# ---------- GET /check ----------
@router.get("/check", response_model=ActivationCodeCheckResponse)
def check_activation_code(code: str, db: Session = Depends(get_db)):
    hashed = hash_code(code)
    entry = db.query(ActivationCode).filter(ActivationCode.code == hashed).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Code not found")
    if entry.is_used:
        return {"status": "used"}
    return {"status": "valid", "expires_in": f"{entry.duration_days} days"}

# ---------- POST /activate ----------
@router.post("/activate", response_model=ActivationCodeActivateResponse)
def activate_subscription(request: ActivationCodeActivateRequest, db: Session = Depends(get_db)):
    hashed = hash_code(request.code)
    entry = db.query(ActivationCode).filter(ActivationCode.code == hashed).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Code not found")
    if entry.is_used:
        raise HTTPException(status_code=400, detail="Code already used")

    user = db.query(User).filter(User.id == request.user_id).first()
    if not user:
        user = User(id=request.user_id, name="New User")
        db.add(user)
        db.commit()
        db.refresh(user)

    now_utc = datetime.now(timezone.utc)
    current_exp = user.premium_expires_at or now_utc
    if current_exp.tzinfo is None:
        current_exp = current_exp.replace(tzinfo=timezone.utc)
    if current_exp < now_utc:
        current_exp = now_utc

    # Активируем код
    entry.is_used = True
    entry.activated_at = now_utc
    entry.user_id = user.id

    user.premium_expires_at = current_exp + timedelta(days=entry.duration_days)
    user.is_premium = True

    db.commit()
    db.refresh(entry)
    db.refresh(user)

    return {"status": "activated", "until": user.premium_expires_at}

# ---------- POST /generate_code ----------
@router.post("/generate_code", status_code=status.HTTP_201_CREATED, response_model=dict)
def generate_activation_code(duration_days: int = 30, db: Session = Depends(get_db)):
    raw_code = str(uuid.uuid4())
    hashed = hash_code(raw_code)
    new_code = ActivationCode(code=hashed, duration_days=duration_days, is_used=False)
    db.add(new_code)
    db.commit()
    db.refresh(new_code)
    return {"raw_code": raw_code, "hashed_code": hashed, "duration_days": duration_days}

# ---------- GET /history ----------
@router.get("/history", response_model=List[ActivationCodeHistoryResponse])
def get_subscription_history(user_id: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    codes = db.query(ActivationCode).filter(ActivationCode.user_id == user_id).order_by(ActivationCode.activated_at.desc()).all()
    if not codes:
        raise HTTPException(status_code=404, detail="No activation history")

    return codes
