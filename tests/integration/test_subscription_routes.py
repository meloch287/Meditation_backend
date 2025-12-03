from fastapi.testclient import TestClient
from sqlalchemy.orm import Session
from src.models.models import User, ActivationCode
from datetime import datetime, timedelta, timezone
import hashlib

UTC = timezone.utc


def hash_code(code: str) -> str:
    return hashlib.sha256(code.encode()).hexdigest()


def test_gen_code(client: TestClient, db_session: Session):
    resp = client.post("/api/subscription/generate_code?duration_days=30")
    assert resp.status_code == 201
    data = resp.json()
    assert "raw_code" in data
    assert "hashed_code" in data
    assert data["duration_days"] == 30

    code_entry = db_session.query(ActivationCode).filter_by(code=data["hashed_code"]).first()
    assert code_entry is not None
    assert code_entry.duration_days == 30
    assert code_entry.is_used is False


def test_check_valid(client: TestClient):
    resp = client.post("/api/subscription/generate_code?duration_days=60")
    raw_code = resp.json()["raw_code"]

    resp_check = client.get(f"/api/subscription/check?code={raw_code}")
    assert resp_check.status_code == 200
    assert resp_check.json() == {"status": "valid", "expires_in": "60 days"}


def test_check_invalid(client: TestClient):
    resp = client.get("/api/subscription/check?code=INVALID_CODE")
    assert resp.status_code == 404
    assert resp.json() == {"detail": "Code not found"}


def test_check_used(client: TestClient, db_session: Session):
    resp = client.post("/api/subscription/generate_code?duration_days=30")
    raw_code = resp.json()["raw_code"]

    user_id = "used_code_user"
    user = User(id=user_id, name="Test User")
    db_session.add(user)
    db_session.commit()

    client.post("/api/subscription/activate", json={"code": raw_code, "user_id": user_id})
    resp_check = client.get(f"/api/subscription/check?code={raw_code}")
    assert resp_check.status_code == 200
    assert resp_check.json() == {"status": "used", "expires_in": None}


def test_activate_new(client: TestClient, db_session: Session):
    resp = client.post("/api/subscription/generate_code?duration_days=30")
    raw_code = resp.json()["raw_code"]

    user_id = "new_user"
    user = User(id=user_id, name="Test User")
    db_session.add(user)
    db_session.commit()

    resp_activate = client.post("/api/subscription/activate", json={"code": raw_code, "user_id": user_id})
    assert resp_activate.status_code == 200
    data = resp_activate.json()
    assert data["status"] == "activated"
    assert "until" in data

    user = db_session.query(User).filter_by(id=user_id).first()
    assert user.is_premium is True
    assert user.premium_expires_at.replace(tzinfo=UTC) > datetime.now(UTC)
    code_entry = db_session.query(ActivationCode).filter_by(code=hash_code(raw_code)).first()
    assert code_entry.is_used is True
    assert code_entry.user_id == user_id


def test_extend_premium(client: TestClient, db_session: Session):
    user_id = "premium_user"
    user = User(id=user_id, name="Premium User", is_premium=True, premium_expires_at=datetime.now(UTC) + timedelta(days=10))
    db_session.add(user)
    db_session.commit()
    initial_exp = user.premium_expires_at

    resp = client.post("/api/subscription/generate_code?duration_days=30")
    raw_code = resp.json()["raw_code"]
    client.post("/api/subscription/activate", json={"code": raw_code, "user_id": user_id})

    user = db_session.query(User).filter_by(id=user_id).first()
    assert user.premium_expires_at.replace(tzinfo=UTC) >= initial_exp.replace(tzinfo=UTC) + timedelta(days=30) - timedelta(seconds=1)


def test_activate_invalid(client: TestClient, db_session: Session):
    user_id = "invalid_user"
    user = User(id=user_id, name="Test User")
    db_session.add(user)
    db_session.commit()

    resp = client.post("/api/subscription/activate", json={"code": "NON_EXISTENT_CODE", "user_id": user_id})
    assert resp.status_code == 404
    assert resp.json() == {"detail": "Code not found"}


def test_activate_used(client: TestClient, db_session: Session):
    resp = client.post("/api/subscription/generate_code?duration_days=30")
    raw_code = resp.json()["raw_code"]

    user1 = User(id="user1", name="User1")
    user2 = User(id="user2", name="User2")
    db_session.add_all([user1, user2])
    db_session.commit()

    client.post("/api/subscription/activate", json={"code": raw_code, "user_id": "user1"})
    resp2 = client.post("/api/subscription/activate", json={"code": raw_code, "user_id": "user2"})
    assert resp2.status_code == 400
    assert resp2.json() == {"detail": "Code already used"}


def test_subscription_history_success(client: TestClient, db_session: Session):
    user_id = "history_user"
    user = User(id=user_id, name="History User")
    db_session.add(user)
    db_session.commit()

    raw_codes = []
    for days in [10, 20]:
        resp = client.post(f"/api/subscription/generate_code?duration_days={days}")
        raw_codes.append(resp.json()["raw_code"])
        client.post("/api/subscription/activate", json={"code": raw_codes[-1], "user_id": user_id})

    resp_hist = client.get(f"/api/subscription/history?user_id={user_id}")
    assert resp_hist.status_code == 200
    data = resp_hist.json()
    assert len(data) == 2
    for entry in data:
        assert "code" in entry
        assert "activated_at" in entry
        assert "duration_days" in entry


def test_subscription_history_user_not_found(client: TestClient):
    resp = client.get("/api/subscription/history?user_id=nonexistent_user")
    assert resp.status_code == 404
    assert resp.json() == {"detail": "User not found"}


def test_subscription_history_empty(client: TestClient, db_session: Session):
    user_id = "empty_history_user"
    user = User(id=user_id, name="Empty User")
    db_session.add(user)
    db_session.commit()

    resp = client.get(f"/api/subscription/history?user_id={user_id}")
    assert resp.status_code == 404
    assert resp.json() == {"detail": "No activation history"}
