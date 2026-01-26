from sqlalchemy import select, insert, delete, text, update, distinct

from app.database import async_session_maker
from app.dao.base import BaseDAO
from app.servers.models import Servers

class ServersDAO(BaseDAO):
    model = Servers

    @classmethod
    async def get_all_locations(cls):
        async with async_session_maker() as session:
            query = select(distinct(cls.model.location))
            result = await session.execute(query)
            return result.scalars().all()