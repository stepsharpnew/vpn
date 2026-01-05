from app.dao.base import BaseDAO
from app.users.models import Users, UsersVip

class UsersDAO(BaseDAO):
    model = Users

class UsersVipDAO(BaseDAO):
    model = UsersVip