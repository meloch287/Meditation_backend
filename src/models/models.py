import uuid
from sqlalchemy import create_engine, Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import declarative_base, sessionmaker, relationship
from datetime import datetime, timezone

DATABASE_URL = "sqlite:///./app.db"

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# ----------------------
# Пользователи
# ----------------------
class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, default="User")
    is_premium = Column(Boolean, default=False)
    premium_expires_at = Column(DateTime(timezone=True), nullable=True)

    # ✅ Новое поле для хранения последней проигранной медитации
    last_played_meditation_id = Column(Integer, ForeignKey("meditations.id"), nullable=True)

    # ✅ Связи
    activation_codes = relationship("ActivationCode", back_populates="user", cascade="all, delete-orphan")
    last_played_meditation = relationship("Meditation", foreign_keys=[last_played_meditation_id])

    def has_active_premium(self) -> bool:
        """Проверка активного премиум-статуса."""
        return (
            self.is_premium
            and self.premium_expires_at is not None
            and self.premium_expires_at > datetime.now(timezone.utc)
        )


# ----------------------
# Медитации
# ----------------------
class Meditation(Base):
    __tablename__ = "meditations"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String)
    duration_seconds = Column(Integer)
    audio_url = Column(String)
    is_premium = Column(Boolean, default=False)
    category = Column(String, index=True)


# ----------------------
# Активационные коды
# ----------------------
class ActivationCode(Base):
    __tablename__ = "activation_codes"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(String, unique=True, index=True)
    duration_days = Column(Integer)
    is_used = Column(Boolean, default=False)
    activated_at = Column(DateTime, nullable=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=True)
    expires_at = Column(DateTime(timezone=True), nullable=True)

    # ✅ Связь с пользователем
    user = relationship("User", back_populates="activation_codes")


# ----------------------
# Сообщения чата
# ----------------------
class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(String, primary_key=True, index=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, index=True, nullable=False)
    content = Column(String, nullable=False)
    is_user = Column(Boolean, nullable=False)  # True если пользователь, False если AI
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)


# ----------------------
# Работа с БД
# ----------------------
def create_db_tables():
    Base.metadata.create_all(bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


if __name__ == "__main__":
    create_db_tables()
