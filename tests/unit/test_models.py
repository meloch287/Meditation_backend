import pytest
from datetime import datetime, timedelta, timezone
from src.models.models import User, Meditation, ActivationCode
from datetime import timezone

UTC = timezone.utc

def test_user_model():
    user = User(id="test_user_id", name="Test User", is_premium=False)
    assert user.id == "test_user_id"
    assert user.name == "Test User"
    assert user.is_premium is False
    assert user.premium_expires_at is None
    assert user.has_active_premium() == False

def test_user_premium_status():
    user = User(
        id="premium_user",
        name="Premium User",
        is_premium=True,
        premium_expires_at=datetime.now(UTC) + timedelta(days=30)
    )
    assert user.is_premium == True
    assert user.premium_expires_at is not None
    assert user.has_active_premium() == True

def test_meditation_model():
    meditation = Meditation(
        id=1,
        title="Stress Relief",
        description="A meditation for stress relief.",
        duration_seconds=600,
        audio_url="https://example.com/audio/stress.mp3",
        is_premium=False,
        category="Снятие стресса"
    )
    assert meditation.id == 1
    assert meditation.title == "Stress Relief"
    assert meditation.description == "A meditation for stress relief."
    assert meditation.duration_seconds == 600
    assert meditation.audio_url == "https://example.com/audio/stress.mp3"
    assert meditation.is_premium == False
    assert meditation.category == "Снятие стресса"

def test_premium_meditation_model():
    meditation = Meditation(
        id=2,
        title="Deep Sleep",
        description="A meditation for deep sleep.",
        duration_seconds=1200,
        audio_url="https://example.com/audio/sleep.mp3",
        is_premium=True,
        category="Сон"
    )
    assert meditation.is_premium == True

def test_activation_code_model():
    code = ActivationCode(
        id=1,
        code="hashed_code_123",
        duration_days=30,
        is_used=False,
        activated_at=None,
        user_id=None
    )
    assert code.id == 1
    assert code.code == "hashed_code_123"
    assert code.duration_days == 30
    assert code.is_used == False
    assert code.activated_at is None
    assert code.user_id is None

def test_used_activation_code():
    now = datetime.now(UTC)
    code = ActivationCode(
        id=2,
        code="hashed_code_456",
        duration_days=90,
        is_used=True,
        activated_at=now,
        user_id="some_user_id"
    )
    assert code.is_used == True
    assert code.activated_at == now
    assert code.user_id == "some_user_id"
