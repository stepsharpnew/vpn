from random import randint
from fastapi import APIRouter, Response, Depends, HTTPException, status
from app.cache import redis
from app.auth.auth import authenticate_user, get_password_hash
from app.auth.dependecies import get_current_user
from app.exceptions import VerifyOldPasswordException
from app.users.dao import UsersDAO, UsersVipDAO
from app.users.models import Users, UsersVip
from app.users.schemas import SChangePassword, SForgotPassword, SVerifyCode
from app.sessions.schemas import VpnConfig
from app.sessions.dao import SessionsDAO
from app.servers.models import Servers
from app.servers.dao import ServersDAO
from app.dao.base import BaseDAO
import uuid

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


@router.get('/me/vpn-config', response_model=VpnConfig)
async def get_vpn_config(current_user: dict = Depends(get_current_user)):
    """
    Registered/VIP flow: получение VPN конфигурации для авторизованных пользователей
    """
    user_id = current_user['id']
    
    # Проверяем, является ли пользователь VIP
    vip_user = await UsersVipDAO.find_by_id(id=user_id)
    is_vip = vip_user is not None
    
    # Получаем серверы
    servers = await ServersDAO.find_all()
    if not servers:
        # Если серверов нет, создаем тестовый сервер для разработки
        server = await ServersDAO.add(
            name_server='Test Server',
            location='Test Location',
            ip_address='127.0.0.1',
            port='51820',
            dns='8.8.8.8',
            public_key='test_public_key',
        )
    else:
        server = servers[0]  # В реальной системе здесь должна быть логика выбора сервера
    
    # Создаем сессию
    session = await SessionsDAO.add(
        user=user_id,
        server=server['id'],
        isvip=is_vip
    )
    
    # Генерируем VPN credentials
    # Для VIP пользователей могут быть специальные настройки
    if is_vip:
        username = f"vip_{session['id']}"
        # VIP пользователи могут иметь приоритетные серверы или дополнительные опции
    else:
        username = f"user_{session['id']}"
    
    vpn_config = VpnConfig(
        server_ip=server.get('ip_address', '127.0.0.1'),
        server_port=int(server.get('port', '51820')) if server.get('port') else 51820,
        username=username,
        password=str(uuid.uuid4()),
        dns=server.get('dns'),
        public_key=server.get('public_key'),
        config_data={
            'session_id': str(session['id']),
            'is_vip': is_vip
        }
    )
    
    return vpn_config