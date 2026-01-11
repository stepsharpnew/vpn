from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Response, Depends, Request, HTTPException, status
from app.config import settings
from app.exceptions import ErrorLoginException, ExistingUserExeption, ExpireTokenExeption, UncorectTokenExeption
from app.auth.auth import authenticate_user, create_access_token, get_password_hash, create_refresh_token
from app.auth.dao import RefreshTokensDAO
from app.auth.dependecies import get_current_user, get_device_id_token
from app.auth.schemas import SUserRegister, SUserLogin, SFirstTimeInitUser
from app.users.dao import UsersDAO
from app.users.models import Users
from jose import jwt, JWTError


router = APIRouter(prefix='/auth',
                   tags=['Авторизация'],)


@router.post('/first_time_init_user')
async def first_time_init_user(user_data: SFirstTimeInitUser):
    await UsersDAO.add(device_id = user_data.device_id)
    return 'ok'

@router.post('/register')
async def register_user(user_data: SUserRegister, current_user: Users = Depends(get_current_user)):
    existing_user = await UsersDAO.find_one_or_none(email=user_data.email)
    if existing_user:
        raise ExistingUserExeption
    hashed_password = get_password_hash(user_data.password)

    return await UsersDAO.update_by_id(current_user['id'], email=user_data.email, hashed_password=hashed_password) 


@router.post('/login')
async def login_user(response: Response, user_data: SUserLogin, request: Request, current_user: Users = Depends(get_current_user)):
    user = await authenticate_user(user_data.email, user_data.password)
    if not user:
        raise ErrorLoginException
    access_token = create_access_token({'sub': str(user.id)})
    refresh_token = create_refresh_token()

    expire_at = (datetime.now(timezone.utc) + timedelta(seconds=settings.MAX_AGE_REFRESH_TOKEN)).timestamp()
    await RefreshTokensDAO.add(user_id=user.id,
                               token=refresh_token,
                               expires_at=str(int(expire_at)),
                               device_id=request.headers.get('Device_id'))

    await UsersDAO.update_by_id(current_user['id'], is_vip=True) 
    
    return {'access_token': access_token}


@router.post('/logout')
async def logout_user(response: Response, request: Request, current_user: Users = Depends(get_current_user)):
    # убрать флаг с вип юзеру
    await UsersDAO.update_by_id(current_user['id'], is_vip=False) 

    return 'ok'


@router.post('/me')
async def me_user(current_user: Users = Depends(get_current_user)):
    return current_user


@router.post('/refresh')
async def refresh_token(response: Response, request: Request, access_token: str, device_id: str = Depends(get_device_id_token)):
    """
    Обновление access token 
    """
    try:
        payload = jwt.decode(
            access_token, settings.SECRET_WORD, settings.HASH_ALGORITHM, options={"verify_exp": False}
        )
    except JWTError as e:
        raise UncorectTokenExeption

    user_id: str = payload['sub']
    if not user_id:
        raise UncorectTokenExeption

    refresh_token_data = await RefreshTokensDAO.find_refresh_token(user_id=user_id, device_id=device_id)
        
    if refresh_token_data:
        if int(refresh_token_data.expires_at) > datetime.now(timezone.utc).timestamp():
            new_access_token = create_access_token({'sub': user_id})
            await UsersDAO.update_by_id(user_id, is_vip=True)
            return {'access_token': new_access_token}
        else:
            await UsersDAO.update_by_id(user_id, is_vip=False) 
            raise ExpireTokenExeption
    else:
        await UsersDAO.update_by_id(user_id, is_vip=False) 
        raise ExpireTokenExeption
    
    
