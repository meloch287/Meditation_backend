from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from dotenv import load_dotenv
import os
from datetime import datetime, timezone
from starlette.concurrency import run_in_threadpool
from src.models.models import ChatMessage, get_db

load_dotenv()

router = APIRouter(tags=["chat"])


def get_openai_client():
    try:
        from openai import OpenAI
        return OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
    except Exception:
        return None


SYSTEM_PROMPT = """
Ты — эмпатичный и спокойный ИИ-психолог.
Твоя задача — помогать пользователю осознать свои эмоции, снять тревогу, поддержать его и направить мягко к самопомощи.
Не давай медицинских диагнозов и не советуй лекарства.
Отвечай кратко (2–5 предложений), с теплом и пониманием.
"""


class ChatRequest(BaseModel):
    user_id: str
    message: str


class ChatResponse(BaseModel):
    response: str


@router.post("/", response_model=ChatResponse)
async def chat_with_psychologist(request: ChatRequest, db: Session = Depends(get_db)):
    if not request.user_id:
        raise HTTPException(status_code=400, detail="user_id is required")

    client = get_openai_client()

    history = db.query(ChatMessage).filter(
        ChatMessage.user_id == request.user_id
    ).order_by(ChatMessage.created_at.asc()).all()

    messages = [{"role": "system", "content": SYSTEM_PROMPT}]
    for msg in history:
        messages.append({
            "role": "user" if msg.is_user else "assistant",
            "content": msg.content
        })
    messages.append({"role": "user", "content": request.message})

    now = datetime.now(timezone.utc)
    db.add(ChatMessage(
        user_id=request.user_id,
        content=request.message,
        is_user=True,
        created_at=now
    ))
    db.commit()

    try:
        def create_completion():
            return client.chat.completions.create(
                model="gpt-4o-mini",
                messages=messages,
                max_tokens=150,
                temperature=0.7
            )

        if client:
            completion = await run_in_threadpool(create_completion)
            response_text = completion.choices[0].message.content.strip()
        else:
            raise Exception("OpenAI client not initialized")

    except Exception:
        response_text = f"Это пример ответа ИИ на сообщение: '{request.message}'."

    db.add(ChatMessage(
        user_id=request.user_id,
        content=response_text,
        is_user=False,
        created_at=datetime.now(timezone.utc)
    ))
    db.commit()

    return ChatResponse(response=response_text)


@router.get("/history", response_model=list[ChatResponse])
def get_chat_history(user_id: str, db: Session = Depends(get_db)):
    if not user_id:
        raise HTTPException(status_code=400, detail="user_id is required")

    messages = db.query(ChatMessage).filter(
        ChatMessage.user_id == user_id
    ).order_by(ChatMessage.created_at.asc()).all()

    return [ChatResponse(response=m.content) for m in messages]
