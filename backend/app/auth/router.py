from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Response, Depends, Request
from app.config import settings
from app.exceptions import ErrorLoginException, ExistingUserExeption
from app.auth.auth import authenticate_user, create_access_token, get_password_hash, create_refresh_token
from app.auth.dao import RefreshTokensDAO
from app.auth.dependecies import get_current_user
from app.auth.schemas import SUserRegister, SUserLogin
from app.users.dao import UsersDAO, UsersVipDAO
from app.users.models import Users, UsersVip


router = APIRouter(prefix='/auth',
                   tags=['Авторизация'],)


@router.post('/register')
async def register_user(user_data: SUserRegister):
    existing_user = await UsersVipDAO.find_one_or_none(email=user_data.email)
    if existing_user:
        raise ExistingUserExeption
    hashed_password = get_password_hash(user_data.password)

    return await UsersVipDAO.add(email=user_data.email, hashed_password=hashed_password)


@router.post('/login')
async def login_user(response: Response, user_data: SUserLogin, request: Request):
    user = await authenticate_user(user_data.email, user_data.password)
    if not user:
        raise ErrorLoginException
    access_token = create_access_token({'sub': str(user.id)})
    refresh_token = create_refresh_token()

    # response.set_cookie('access_token', access_token, httponly=True)
    # response.set_cookie('refresh_token', refresh_token, httponly=True, max_age=settings.MAX_AGE_REFRESH_TOKEN)

    expire_at = (datetime.now(timezone.utc) + timedelta(seconds=settings.MAX_AGE_REFRESH_TOKEN)).timestamp()
    await RefreshTokensDAO.add(user_id=user.id,
                               token=refresh_token,
                               expires_at=str(int(expire_at)),
                               user_agent=request.headers.get('User-Agent'))
    
    return access_token, refresh_token


@router.post('/logout')
async def logout_user(response: Response, request: Request):
    # refresh_token = request.cookies.get('refresh_token')
    # if refresh_token:
    #     await RefreshTokensDAO.delete(token=refresh_token)

    # response.delete_cookie('access_token')
    # response.delete_cookie('refresh_token')

    return 'ok'


@router.post('/me')
async def me_user(current_user: UsersVip = Depends(get_current_user)):
    return current_user