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

    server_config = random.choice(servers_by_locations)
    return server_config
    
    
