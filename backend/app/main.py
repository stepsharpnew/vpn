from fastapi import FastAPI
from fastapi.openapi.utils import get_openapi
from fastapi.middleware.cors import CORSMiddleware
from app.auth.router import router as router_auth
from app.users.router import router as router_user
from app.sessions.router import router as router_sessions
from app.servers.router import router as router_server

from sqladmin import Admin
from app.admin.auth import authentication_backend
from app.database import engine_nullpool
from app.admin.view import UserAdmin, ServersAdmin, SessionsAdmin

app = FastAPI()

app.include_router(router_auth)
app.include_router(router_user)
app.include_router(router_sessions)
app.include_router(router_server)


def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    
    openapi_schema = get_openapi(
        title="API Documentation",
        version="1.0.0",
        description="Your API",
        routes=app.routes,
    )
    
    # Добавляем Security Schemes для заголовков
    openapi_schema["components"]["securitySchemes"] = {
        "BearerAuth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
            "description": "JWT access token"
        },
        "DeviceId": {
            "type": "apiKey",
            "in": "header",
            "name": "Device_id",
            "description": "Device identifier"
        }
    }
    
    # Применяем схему ко всем endpoints
    openapi_schema["security"] = [
        {"BearerAuth": []},
        {"DeviceId": []}
    ]
    
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = custom_openapi


admin = Admin(app, engine_nullpool, authentication_backend=authentication_backend)

admin.add_view(UserAdmin)
admin.add_view(ServersAdmin)
admin.add_view(SessionsAdmin)


origins = [
    'http://localhost:8000',
    '*',
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)