from sqladmin import Admin
from sqladmin.authentication import AuthenticationBackend
from starlette.requests import Request
from starlette.responses import RedirectResponse
from pydantic import EmailStr

from app.auth.auth import authenticate_admin, create_access_token
from app.auth.dependecies import check_admin_access_token, get_current_user
from app.users.dao import UsersDAO
from app.config import settings


class AdminAuth(AuthenticationBackend):
    async def login(self, request: Request) -> bool:
        form = await request.form()
        email, password = form["username"], form["password"]

        user = await authenticate_admin(email, password)
        
        if user:    
            access_token = create_access_token({'sub': str(user.id)})
            request.session.update({"token": access_token})

        return True

    async def logout(self, request: Request) -> bool:
        request.session.clear()
        return True

    async def authenticate(self, request: Request) -> bool:
        token = request.session.get("token")
        if not token:
            return False
        
        user = await check_admin_access_token(token)
        if not user:
            return False

        return True


authentication_backend = AdminAuth(secret_key=settings.SECRET_WORD)