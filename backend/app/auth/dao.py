from sqlalchemy import select, insert, delete, text, update

from app.database import async_session_maker
from app.dao.base import BaseDAO
from app.auth.models import RefreshTokens

class RefreshTokensDAO(BaseDAO):
    model = RefreshTokens

    
    @classmethod
    async def find_refresh_token(cls, user_id: str, token: str, user_agent: str):
        async with async_session_maker() as session:
            query = select(cls.model.__table__.columns).limit(1).filter_by(user_id=user_id, token=token, user_agent=user_agent).order_by(cls.model.expires_at.desc())
            result = await session.execute(query)
            return result.mappings().one_or_none()