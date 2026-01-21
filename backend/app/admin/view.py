from sqladmin import ModelView
from app.users.models import Users
from app.servers.models import Servers
from app.sessions.models import Sessions


class UserAdmin(ModelView, model=Users):
    column_list = [Users.id, Users.device_id, Users.is_blocked, Users.is_vip, Users.email, Users.created_at]
    column_details_exclude_list = [Users.hashed_password]
    can_delete = False
    name = 'Пользователь'
    name_plural = 'Пользователи'
    icon = 'fa-solid fa-user'


class ServersAdmin(ModelView, model=Servers):
    column_list = '__all__'
    can_delete = True
    name = 'Серверы'
    name_plural = 'Серверы'
    icon = 'fa-solid fa-book'


class SessionsAdmin(ModelView, model=Sessions):
    column_list = '__all__'
    can_delete = True
    name = 'Сессии'
    name_plural = 'Сессии'
    icon = 'fa-solid fa-hotel'