from app.dao.base import BaseDAO
from app.sessions.models import Sessions

class SessionsDAO(BaseDAO):
    model = Sessions

