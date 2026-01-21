import uuid
import uuid_utils
from sqlalchemy import Index, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base, str_not_null, str_null, created_at


class Users(Base):
    __tablename__ = 'users'

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid_utils.uuid7)
    device_id: Mapped[str_not_null] = mapped_column(unique=True)
    is_blocked: Mapped[bool] = mapped_column(default=False)
    is_vip: Mapped[bool] = mapped_column(default=False)
    email: Mapped[str_null] = mapped_column(unique=True)
    hashed_password: Mapped[str_null]
    role: Mapped[str_null] = mapped_column(default='user')
    created_at: Mapped[created_at]

    def __str__(self):
        return f'{self.device_id}'


