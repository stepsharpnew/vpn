from ipaddress import ip_address
import uuid
import uuid_utils
from sqlalchemy import Index, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base, str_not_null, str_null, created_at


class Servers(Base):
    __tablename__ = 'servers'

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid_utils.uuid7)
    name_server: Mapped[str_null]
    location: Mapped[str_null]
    ip_address: Mapped[str_null]
    port: Mapped[str_null]
    dns: Mapped[str_null]
    public_key: Mapped[str_null]
    Jc: Mapped[str_null]
    Jmin: Mapped[str_null]
    Jmax: Mapped[str_null]
    s1: Mapped[str_null]
    s2: Mapped[str_null]
    h1: Mapped[str_null]
    h2: Mapped[str_null]
    h3: Mapped[str_null]
    h4: Mapped[str_null]

    def __str__(self):
        return f'{self.name_server}'