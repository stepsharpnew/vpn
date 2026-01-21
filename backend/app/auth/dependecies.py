from re import A
from fastapi import Request, Depends, Response, HTTPException, status
from jose import jwt, JWTError
from datetime import datetime, timezone

from app.config import settings
from app.auth.auth import create_access_token
from app.auth.dao import RefreshTokensDAO
from app.users.dao import UsersDAO
from app.exceptions import NoTokenExeption, UncorectTokenExeption, ExpireTokenExeption, UserIsBlocked


def get_access_token(request: Request) -> str:
    """Извлекает access token из заголовка Authorization"""
    authorization = request.headers.get('Authorization')
    if not authorization:
        return None
    
    parts = authorization.split(' ')
    if len(parts) != 2 or parts[0].lower() != 'bearer':
        return None
    
    return parts[1]


def get_device_id_token(request: Request) -> str:
    """Извлекает device_id из заголовка Device_id"""
    device_id = request.headers.get('Device_id')
    if not device_id:
        return None
    
    return device_id


def get_token(request: Request):
    try:
        token = request.cookies['token']
    except:
        raise NoTokenExeption
    return token


async def get_current_user(response: Response,
                           request: Request,
                           access_token: str = Depends(get_access_token),
                           device_id: str = Depends(get_device_id_token)):

    if not device_id:
        raise UncorectTokenExeption

    if not access_token:
        user = await UsersDAO.find_one_or_none(device_id=device_id)
        if not user:
            user = await UsersDAO.add(device_id=device_id)

        if user.is_blocked:
            raise UserIsBlocked
        
        user_dict = {'id': user.id,
                     'device_id': user.device_id,
                     'is_vip': user.is_vip,
                     'is_blocked': user.is_blocked}

        return user_dict
    
    try:
        payload = jwt.decode(
            access_token, settings.SECRET_WORD, settings.HASH_ALGORITHM, options={"verify_exp": False}
        )
    except JWTError as e:
        raise UncorectTokenExeption
    
    user_id: str = payload['sub']
    if not user_id:
        raise UncorectTokenExeption
    
    expire: str = payload['exp']
    if (not expire) or (int(expire) < datetime.now(timezone.utc).timestamp()):
        await UsersDAO.update_by_id(user_id, is_vip=False) 
        raise ExpireTokenExeption
        
    user = await UsersDAO.find_by_id(user_id)
    if not user:
        raise UncorectTokenExeption
    
    user_dict = {'id': user.id,
                 'device_id': user.device_id,
                 'is_vip': user.is_vip,
                 'email': user.email,
                 'is_blocked': user.is_blocked}

    return user_dict



async def check_admin_access_token(token: str = Depends(get_token)):
    try:
        payload = jwt.decode(
            token, settings.SECRET_WORD, settings.HASH_ALGORITHM
        )
    except JWTError:
        raise UncorectTokenExeption
    
    expire: str = payload['exp']
    if (not expire) or (int(expire) < datetime.now(timezone.utc).timestamp()):
        raise ExpireTokenExeption
    
    user_id: str = payload['sub']
    if not user_id:
        raise UncorectTokenExeption
    
    user = await UsersDAO.find_one_or_none(id=user_id, role="admin")
    if not user:
        raise UncorectTokenExeption
    
    user_dict = {'id': user.id,
                 'email': user.email}

    return user_dict