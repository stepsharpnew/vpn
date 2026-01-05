import uuid
import uuid_utils
from sqlalchemy import Index, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base, str_not_null, str_null, created_at


class RefreshTokens(Base):
    __tablename__ = 'refresh_tokens'

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid_utils.uuid7)
    user_id: Mapped[uuid.UUID] = mapped_column(nullable=True)
    token: Mapped[str_null] 
    expires_at: Mapped[str_null]
    user_agent: Mapped[str_null]

    def __str__(self):
        return f'{self.user_id}'