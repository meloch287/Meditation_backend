import pytest
from datetime import datetime, timedelta, timezone
from src.models.models import User
from datetime import timezone

UTC = timezone.utc

def test_user_has_active_premium_method():
    # Пользователь с активной подпиской
    user = User(
        id="test_user_active",
        is_premium=True,
        premium_expires_at=datetime.now(UTC) + timedelta(days=10)
    )
    assert user.is_premium == True
    assert user.premium_expires_at > datetime.now(UTC)
    assert user.has_active_premium() == True

def test_user_has_expired_premium_method():
    # с истёкшей подпиской
    user = User(
        id="test_user_expired",
        is_premium=True,
        premium_expires_at=datetime.now(UTC) - timedelta(days=1)
    )
    assert user.is_premium == True  # модель сама не меняет is_premium
    assert user.has_active_premium() == False

def test_user_without_premium_method():
    # без премиум-подписки
    user = User(
        id="test_user_non_premium",
        is_premium=False,
        premium_expires_at=None
    )
    assert user.is_premium == False
    assert user.has_active_premium() == False
