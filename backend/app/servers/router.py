from fastapi import APIRouter, Depends, HTTPException, status
from app.users.dao import UsersDAO
from app.sessions.dao import SessionsDAO
from app.servers.models import Servers
from app.servers.dao import ServersDAO
from app.dao.base import BaseDAO
from app.auth.dependecies import get_current_user
import uuid

router = APIRouter(prefix='/servers',
                   tags=['Сервера'])

@router.get('/get_all_locations_servers')
async def get_all_locations_servers():
    locations = await ServersDAO.get_all_locations()
    return locations

@router.post('/add_server')
async def add_server(name_server: str, location: str):
    new_server = await ServersDAO.add(name_server = name_server, location = location)
    return new_server

# @router.get('/get_vpn_config')
# async def get_vpn_config(current_user: dict = Depends(get_current_user)):
#     """
#     Registered/VIP flow: получение VPN конфигурации для авторизованных пользователей
#     """
#     user_id = current_user['id']
    
#     # Проверяем, является ли пользователь VIP
#     vip_user = await UsersVipDAO.find_by_id(id=user_id)
#     is_vip = vip_user is not None
    
#     # Получаем серверы
#     servers = await ServersDAO.find_all()
#     if not servers:
#         # Если серверов нет, создаем тестовый сервер для разработки
#         server = await ServersDAO.add(
#             name_server='Test Server',
#             location='Test Location',
#             ip_address='127.0.0.1',
#             port='51820',
#             dns='8.8.8.8',
#             public_key='test_public_key',
#         )
#     else:
#         server = servers[0]  # В реальной системе здесь должна быть логика выбора сервера
    
#     # Создаем сессию
#     session = await SessionsDAO.add(
#         user=user_id,
#         server=server['id'],
#         isvip=is_vip
#     )
    
#     # Генерируем VPN credentials
#     # Для VIP пользователей могут быть специальные настройки
#     if is_vip:
#         username = f"vip_{session['id']}"
#         # VIP пользователи могут иметь приоритетные серверы или дополнительные опции
#     else:
#         username = f"user_{session['id']}"
    
#     vpn_config = VpnConfig(
#         server_ip=server.get('ip_address', '127.0.0.1'),
#         server_port=int(server.get('port', '51820')) if server.get('port') else 51820,
#         username=username,
#         password=str(uuid.uuid4()),
#         dns=server.get('dns'),
#         public_key=server.get('public_key'),
#         config_data={
#             'session_id': str(session['id']),
#             'is_vip': is_vip
#         }
#     )
    
#     return vpn_config