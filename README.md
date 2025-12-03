# Meditation Backend

REST API backend for a meditation mobile application built with FastAPI.

## Tech Stack

- Python 3.11+
- FastAPI
- SQLAlchemy (SQLite)
- OpenAI API (GPT-4o-mini)
- Docker

## Project Structure

```
src/
├── main.py
├── models/
│   └── models.py
├── routes/
│   ├── user_routes.py
│   ├── meditation_routes.py
│   ├── subscription_routes.py
│   └── chat_routes.py
└── static/
    ├── index.html
    └── test_chat.html
tests/
├── conftest.py
├── unit/
└── integration/
```

## Features

- User management (CRUD)
- Meditation catalog with premium content filtering
- Subscription system with activation codes
- AI psychologist chat (OpenAI integration)
- Last played meditation tracking

## API Endpoints

### Users `/api/users`
| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | List all users |
| GET | `/{user_id}` | Get user by ID |
| POST | `/` | Create user |
| PUT | `/{user_id}` | Update user |
| DELETE | `/{user_id}` | Delete user |
| POST | `/{user_id}/last_played/{meditation_id}` | Set last played |
| GET | `/{user_id}/last_played` | Get last played |
| GET | `/{user_id}/subscriptions` | Get activation history |

### Meditations `/api/meditations`
| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | List meditations (filter by category, user_id) |
| GET | `/{meditation_id}` | Get meditation by ID |
| POST | `/seed` | Seed sample data |

### Subscriptions `/api/subscription`
| Method | Path | Description |
|--------|------|-------------|
| GET | `/check?code=` | Check activation code status |
| POST | `/activate` | Activate subscription code |
| POST | `/generate_code` | Generate new activation code |
| GET | `/history?user_id=` | Get user activation history |

### Chat `/api/chat`
| Method | Path | Description |
|--------|------|-------------|
| POST | `/` | Send message to AI psychologist |
| GET | `/history?user_id=` | Get chat history |

## Installation

### Local Setup

```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows

pip install -r requirements.txt
```

### Environment Variables

Create `.env` file:
```
OPENAI_API_KEY=your_api_key_here
```

### Run Server

```bash
uvicorn src.main:app --host 0.0.0.0 --port 8000
```

### Docker

```bash
docker-compose build
docker-compose up
```

Server available at `http://localhost:8000`

## Testing

```bash
pytest --cov=src tests/
```

## API Documentation

- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## License

MIT
