from fastapi import FastAPI
from contextlib import asynccontextmanager
from starlette.staticfiles import StaticFiles
from starlette.responses import FileResponse
from dotenv import load_dotenv
import uvicorn

from src.models.models import create_db_tables
from src.routes import user_routes, meditation_routes, subscription_routes, chat_routes

load_dotenv()


@asynccontextmanager
async def lifespan(app: FastAPI):
    create_db_tables()
    yield


app = FastAPI(lifespan=lifespan)

app.mount("/static", StaticFiles(directory="src/static"), name="static")

app.include_router(user_routes.router)
app.include_router(meditation_routes.router, prefix="/api/meditations", tags=["meditations"])
app.include_router(subscription_routes.router, prefix="/api/subscription", tags=["subscription"])
app.include_router(chat_routes.router, prefix="/api/chat", tags=["chat"])


@app.get("/", include_in_schema=False)
async def read_index():
    return FileResponse("src/static/index.html")


@app.get("/test-chat", include_in_schema=False)
async def read_test_chat():
    return FileResponse("src/static/test_chat.html")


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
