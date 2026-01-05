import uuid
import uuid_utils
from sqlalchemy import Index, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base, str_not_null, str_null, created_at


class Sessions(Base):
    __tablename__ = 'sessions'

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid_utils.uuid7)
    user: Mapped[uuid.UUID] = mapped_column(ForeignKey('users.id'))
    server: Mapped[uuid.UUID] = mapped_column(ForeignKey('servers.id'))
    created_at: Mapped[created_at]
    isvip: Mapped[bool] = mapped_column(default=False)


    def __str__(self):
        return f'{self.user_id}'
