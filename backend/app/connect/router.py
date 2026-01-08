from fastapi import APIRouter, Depends, HTTPException, status
from app.connect.schemas import ConnectRequest, VpnConfig
from app.users.dao import UsersDAO
from app.sessions.dao import SessionsDAO
from app.servers.models import Servers
from app.dao.base import BaseDAO
import uuid

router = APIRouter(prefix='/connect',
                   tags=['Подключение VPN'])


class ServersDAO(BaseDAO):
    model = Servers


@router.post('/request', response_model=VpnConfig)
async def connect_request(request: ConnectRequest):
    """
    Guest flow: запрос на подключение для неавторизованных пользователей
    """
    device_id = request.device_id
    
    # Проверяем, заблокировано ли устройство
    user = await UsersDAO.find_one_or_none(device_id=device_id)
    if user and user.get('is_blocked'):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail='Устройство заблокировано'
        )
    
    # Если пользователя нет, создаем нового
    if not user:
        user = await UsersDAO.add(device_id=device_id, mac_address='')
    
    # Получаем случайный сервер (пока нет логики выбора, берем первый доступный)
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
        server = servers[0]
    
    # Создаем сессию
    session = await SessionsDAO.add(
        user=user['id'],
        server=server['id'],
        isvip=False
    )
    
    # Генерируем временные VPN credentials
    # В реальной системе здесь должна быть интеграция с VPN сервером
    # Пока возвращаем mock данные
    vpn_config = VpnConfig(
        server_ip=server.get('ip_address', '127.0.0.1'),
        server_port=int(server.get('port', '51820')) if server.get('port') else 51820,
        username=f"guest_{session['id']}",
        password=str(uuid.uuid4()),
        dns=server.get('dns'),
        public_key=server.get('public_key'),
        config_data={
            'session_id': str(session['id']),
            'is_vip': False
        }
    )
    
    return vpn_config

