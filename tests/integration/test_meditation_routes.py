from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from src.models.models import Meditation, User
from datetime import datetime, timedelta, timezone

UTC = timezone.utc


def test_seed_med(client: TestClient, db_session: Session):
    meditations = [Meditation(title=f"Med {i}", description="Desc", duration_seconds=300, audio_url="url", is_premium=False, category="Sleep") for i in range(3)]
    db_session.add_all(meditations)
    db_session.commit()

    resp = client.get("/api/meditations/")
    assert resp.status_code == 200
    data = resp.json()
    assert all(m["is_premium"] is False for m in data)


def test_premium_access(client: TestClient, db_session: Session):
    user = User(id="premium_user", name="Premium", is_premium=True, premium_expires_at=datetime.now(UTC) + timedelta(days=30))
    db_session.add(user)
    meditations = [Meditation(title=f"Med {i}", description="Desc", duration_seconds=300, audio_url="url", is_premium=(i % 2 == 0), category="Sleep") for i in range(6)]
    db_session.add_all(meditations)
    db_session.commit()

    resp = client.get(f"/api/meditations/?user_id={user.id}")
    data = resp.json()
    assert len(data) == 6


def test_filtered_premium(client: TestClient, db_session: Session):
    user = User(id="user_prem", name="User Premium", is_premium=True, premium_expires_at=datetime.now(UTC) + timedelta(days=30))
    db_session.add(user)
    med1 = Meditation(title="Free", description="Free", duration_seconds=300, audio_url="url1", is_premium=False, category="Sleep")
    med2 = Meditation(title="Premium", description="Premium", duration_seconds=600, audio_url="url2", is_premium=True, category="Sleep")
    db_session.add_all([med1, med2])
    db_session.commit()

    resp = client.get(f"/api/meditations/?user_id={user.id}")
    data = resp.json()
    assert any(m["title"] == "Premium" for m in data)


def test_filtered_free(client: TestClient, db_session: Session):
    user = User(id="user_free", name="Free User")
    db_session.add(user)
    med1 = Meditation(title="Free", description="Free", duration_seconds=300, audio_url="url1", is_premium=False, category="Sleep")
    med2 = Meditation(title="Premium", description="Premium", duration_seconds=600, audio_url="url2", is_premium=True, category="Sleep")
    db_session.add_all([med1, med2])
    db_session.commit()

    resp = client.get(f"/api/meditations/?user_id={user.id}")
    data = resp.json()
    assert len(data) == 1
    assert data[0]["title"] == "Free"


def test_last_played(client: TestClient, db_session: Session):
    med = Meditation(title="Meditation 1", description="Desc", duration_seconds=300, audio_url="url", is_premium=False, category="Sleep")
    db_session.add(med)
    db_session.commit()

    user = User(id="user_last", name="Last", last_played_meditation_id=med.id)
    db_session.add(user)
    db_session.commit()

    resp = client.get(f"/api/meditations/{med.id}?user_id={user.id}")
    data = resp.json()
    assert resp.status_code == 200
    assert data["last_played"] is True
