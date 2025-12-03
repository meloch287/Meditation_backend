from fastapi.testclient import TestClient
from unittest.mock import MagicMock, patch
from src.main import app

client = TestClient(app)

mock_openai_client = MagicMock()
mock_choice = MagicMock()
mock_choice.message.content = "Я понимаю ваши чувства, всё будет хорошо."
mock_openai_client.chat.completions.create.return_value.choices = [mock_choice]


@patch("src.routes.chat_routes.get_openai_client", return_value=mock_openai_client)
def test_chat_mock_response(mock_client_func):
    payload = {"user_id": "test_user", "message": "Мне тревожно."}
    response = client.post("/api/chat/", json=payload)

    assert response.status_code == 200
    data = response.json()
    assert data["response"] == "Я понимаю ваши чувства, всё будет хорошо."


@patch("src.routes.chat_routes.get_openai_client", return_value=mock_openai_client)
def test_chat_history_returns_messages(mock_client_func):
    payload = {"user_id": "test_user", "message": "Мне тревожно."}
    client.post("/api/chat/", json=payload)

    response = client.get("/api/chat/history?user_id=test_user")
    assert response.status_code == 200
    data = response.json()
    assert any("Мне тревожно." in item["response"] for item in data)
    assert any("Я понимаю ваши чувства" in item["response"] for item in data)
