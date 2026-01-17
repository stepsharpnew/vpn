"""add_is_vip_to_users

Revision ID: bde400b4a76c
Revises: 5aaf05419b2f
Create Date: 2026-01-14 22:16:25.588679

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


# revision identifiers, used by Alembic.
revision: str = 'bde400b4a76c'
down_revision: Union[str, Sequence[str], None] = '5aaf05419b2f'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # Проверяем, существует ли таблица и колонка
    conn = op.get_bind()
    inspector = inspect(conn)
    
    # Проверяем существование таблицы
    tables = inspector.get_table_names()
    if 'users' not in tables:
        # Если таблицы нет, значит первая миграция не применена
        # В этом случае колонка будет создана первой миграцией
        return
    
    # Проверяем существование колонки
    columns = [col['name'] for col in inspector.get_columns('users')]
    if 'is_vip' not in columns:
        op.add_column('users', sa.Column('is_vip', sa.Boolean(), nullable=False, server_default=sa.text('false')))


def downgrade() -> None:
    """Downgrade schema."""
    # Проверяем, существует ли колонка перед удалением
    conn = op.get_bind()
    inspector = inspect(conn)
    tables = inspector.get_table_names()
    
    if 'users' in tables:
        columns = [col['name'] for col in inspector.get_columns('users')]
        if 'is_vip' in columns:
            op.drop_column('users', 'is_vip')
