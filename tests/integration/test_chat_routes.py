import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
from src.main import app

client = TestClient(app)

def mock_openai_response(*args, **kwargs):
    mock_choice = MagicMock()
    mock_choice.message.content = "Я понимаю ваши чувства, всё будет хорошо."
    mock_completion = MagicMock()
    mock_completion.choices = [mock_choice]
    return mock_completion

@patch("src.routes.chat_routes.client.chat.completions.create", side_effect=mock_openai_response)
def test_chat_mock_response(mock_create):
    payload = {"user_id": "test_user", "message": "Мне тревожно."}
    response = client.post("/api/chat/", json=payload)
    
    assert response.status_code == 200
    data = response.json()
    assert "response" in data
    assert data["response"] == "Я понимаю ваши чувства, всё будет хорошо."

@patch("src.routes.chat_routes.client.chat.completions.create", side_effect=mock_openai_response)
def test_chat_history_returns_messages(mock_create):
    payload = {"user_id": "test_user", "message": "Мне тревожно."}
    client.post("/api/chat/", json=payload)

    response = client.get("/api/chat/history?user_id=test_user")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert any("Мне тревожно." in item["response"] for item in data)
    assert any("Я понимаю ваши чувства" in item["response"] for item in data)
