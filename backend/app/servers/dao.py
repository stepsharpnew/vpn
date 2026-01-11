from sqlalchemy import select, insert, delete, text, update
from app.database import async_session_maker
from app.dao.base import BaseDAO
from app.servers.models import Servers

class ServersDAO(BaseDAO):
    model = Servers