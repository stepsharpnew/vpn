from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.auth.router import router as router_auth
from app.users.router import router as router_user
from app.sessions.router import router as router_sessions

app = FastAPI()

# Настройка CORS для работы с мобильным приложением 
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # В продакшене укажите конкретные домены
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router_auth)
app.include_router(router_user)
app.include_router(router_sessions)