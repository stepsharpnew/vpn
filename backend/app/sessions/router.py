import random
from fastapi import APIRouter, Depends, HTTPException, status
from app.users.dao import UsersDAO
from app.sessions.dao import SessionsDAO
from app.servers.models import Servers
from app.dao.base import BaseDAO
from app.servers.dao import ServersDAO
import uuid
from app.auth.dependecies import get_current_user
from app.users.models import Users
from app.servers.utils import AWGAPIClient

router = APIRouter(prefix='/sessions',
                   tags=['Сессии'])


@router.post('/connect')
async def connect_request(location: str, user: Users = Depends(get_current_user)):
    """коннект к серверу"""
    if location=="all":
        servers_by_locations = await ServersDAO.find_all(is_vip=user["is_vip"], enable=True)
    else:
        servers_by_locations = await ServersDAO.find_all(location=location, is_vip=user["is_vip"], enable=True)

    if not servers_by_locations:
        if user["is_vip"]:
            servers_by_locations = await ServersDAO.find_all(is_vip=True, enable=True)
            if not servers_by_locations:
                servers_by_locations = await ServersDAO.find_all(is_vip=False, enable=True)
        else:
            servers_by_locations = await ServersDAO.find_all(is_vip=False, enable=True)
        
    if not servers_by_locations:
        return None

    server = random.choice(servers_by_locations)
     # Создаем client через Web UI API
    try:
        # Предполагаем, что API запущен на порту 5000 на том же сервере
        api_client = AWGAPIClient(f"http://{server.ip_address}:5000")
        
        # Создаем client
        client_data = await api_client.create_peer(server_ip=server.server_ip, name=user["email"])
        client_data = client_data.get("client")
        return client_data
        # # Сохраняем сессию в БД
        # session = await SessionsDAO.add(
        #     user=user["id"],
        #     server=server.id,
        #     isvip=user["is_vip"],
        #     client_public_key=client_data["public_key"],
        #     client_private_key=client_data["private_key"],
        #     client_ip=client_data["ip_address"],
        #     preshared_key=client_data["preshared_key"]
        # )
        
        # return {
        #     "server": server,
        #     "session_id": session.id,
        #     "client_config": client_config,
        #     "client_ip": peer_data["ip_address"]
        # }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Ошибка при создании peer: {str(e)}"
        )


@router.delete('/disconnect/{session_id}')
async def disconnect_request(session_id: uuid.UUID, user: Users = Depends(get_current_user)):
    """Отключение от сервера"""
    session = await SessionsDAO.find_one_or_none(id=session_id, user=user["id"])
    
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Сессия не найдена"
        )
    
    # Получаем сервер
    server = await ServersDAO.find_by_id(session.server)
    
    # Удаляем peer через API
    api_client = AWGAPIClient(f"http://{server.ip_address}:5000")
    await api_client.delete_peer(session.client_public_key)
    
    # Удаляем сессию из БД
    await SessionsDAO.delete(id=session_id)
    
    return {"status": "disconnected"}
    
    
