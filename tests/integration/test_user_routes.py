import pytest
from datetime import datetime, timedelta, timezone
from src.models.models import User, Meditation
UTC = timezone.utc

# ----------------------------
# GET /api/users
# ----------------------------
def test_get_users(client, db_session):
    u1 = User(id="u1", name="Alice")
    u2 = User(id="u2", name="Bob", premium_expires_at=datetime.now(UTC)+timedelta(days=5))
    db_session.add_all([u1, u2])
    db_session.commit()

    resp = client.get("/api/users/")
    assert resp.status_code == 200
    data = resp.json()
    assert len(data) == 2
    ids = [u["id"] for u in data]
    assert "u1" in ids and "u2" in ids

def test_get_user_by_id(client, db_session):
    u = User(id="user123", name="Charlie")
    db_session.add(u)
    db_session.commit()

    resp = client.get(f"/api/users/{u.id}")
    assert resp.status_code == 200
    data = resp.json()
    assert data["id"] == "user123"
    assert data["name"] == "Charlie"

def test_get_user_not_found(client):
    resp = client.get("/api/users/nonexistent")
    assert resp.status_code == 404
    assert resp.json() == {"detail": "User not found"}

# ----------------------------
# POST /api/users
# ----------------------------
def test_create_user(client, db_session):
    resp = client.post("/api/users/", json={"id": "new_user", "name": "Newbie"})
    assert resp.status_code == 200
    data = resp.json()
    assert data["id"] == "new_user"
    assert data["name"] == "Newbie"
    assert data["is_premium"] is False

def test_create_existing_user(client, db_session):
    user = User(id="existing_user", name="Exist")
    db_session.add(user)
    db_session.commit()

    resp = client.post("/api/users/", json={"id": "existing_user", "name": "Exist"})
    assert resp.status_code == 400
    assert resp.json() == {"detail": "User already exists"}

# ----------------------------
# PUT /api/users/{id}
# ----------------------------
def test_update_user(client, db_session):
    user = User(id="upd_user", name="Old Name")
    db_session.add(user)
    db_session.commit()

    resp = client.put(f"/api/users/{user.id}", json={"name": "New Name"})
    assert resp.status_code == 200
    data = resp.json()
    assert data["name"] == "New Name"

def test_update_user_not_found(client):
    resp = client.put("/api/users/unknown", json={"name": "New Name"})
    assert resp.status_code == 404
    assert resp.json() == {"detail": "User not found"}

# ----------------------------
# DELETE /api/users/{id}
# ----------------------------
def test_delete_user(client, db_session):
    user = User(id="del_user", name="ToDelete")
    db_session.add(user)
    db_session.commit()

    resp = client.delete(f"/api/users/{user.id}")
    assert resp.status_code == 204

def test_delete_user_not_found(client):
    resp = client.delete("/api/users/nonexistent")
    assert resp.status_code == 404
    assert resp.json() == {"detail": "User not found"}

# ----------------------------
# POST /api/users/{user_id}/last_played/{meditation_id}
# ----------------------------
def test_update_last_played(client, db_session):
    user = User(id="lp_user", name="LP User")
    med = Meditation(title="Meditation 1", description="Desc", duration_seconds=200, audio_url="url", is_premium=False, category="Сон")
    db_session.add_all([user, med])
    db_session.commit()

    resp = client.post(f"/api/users/{user.id}/last_played/{med.id}")
    assert resp.status_code == 200
    data = resp.json()
    assert data["last_played_meditation_id"] == med.id

def test_update_last_played_user_not_found(client):
    resp = client.post("/api/users/nonexistent/last_played/1")
    assert resp.status_code == 404
    assert resp.json() == {"detail": "User not found"}

def test_update_last_played_meditation_not_found(client, db_session):
    user = User(id="lp_user2", name="LP User2")
    db_session.add(user)
    db_session.commit()

    resp = client.post(f"/api/users/{user.id}/last_played/9999")
    assert resp.status_code == 404
    assert resp.json() == {"detail": "Meditation not found"}
