from random import randint
from fastapi import APIRouter, Response, Depends
from app.cache import redis
from app.auth.auth import authenticate_user, get_password_hash
from app.auth.dependecies import get_current_user
from app.exceptions import VerifyOldPasswordException
from app.users.dao import UsersDAO, UsersVipDAO
from app.users.models import Users, UsersVip
from app.users.schemas import SChangePassword, SForgotPassword, SVerifyCode

router = APIRouter(prefix='/users',
                   tags=['Пользователи'],)


@router.post('/change_password')
async def change_password(user_data: SChangePassword,
                          current_user: UsersVip = Depends(get_current_user)):
    verify_old_password = await authenticate_user(current_user['email'],
                                                  user_data.old_password)
    
    if not verify_old_password:
        raise VerifyOldPasswordException
    
    new_hashed_password = get_password_hash(user_data.new_password)

    await UsersVipDAO.update_by_id(current_user['id'],
                                hashed_password = new_hashed_password)
    return 'ok'


@router.get('/profile/{id}')
async def get_profile_by_id(profile_id: str):
    profile = None
    try:
        profile = await UsersVipDAO.find_one_or_none(id=profile_id)
    except:
        pass

    return profile


@router.post('/forgot_password')
async def forgot_password(user_data: SForgotPassword):
    code = randint(100000, 999999)
    redis.set(user_data.email, code, 60*15)
    return 'ok'


@router.post('/verify_code')
async def verify_code(user_data: SVerifyCode):
    saved_code = redis.get(user_data.email)
    if user_data.code == int(saved_code):
        redis.delete(user_data.email)
        return True
    return False