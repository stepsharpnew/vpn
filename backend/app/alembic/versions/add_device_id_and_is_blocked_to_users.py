"""add device_id and is_blocked to users

Revision ID: add_device_id_blocked
Revises: f2a5d9dfe7f2
Create Date: 2026-01-06 12:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'add_device_id_blocked'
down_revision: Union[str, Sequence[str], None] = 'f2a5d9dfe7f2'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    # Проверяем, существует ли таблица users
    connection = op.get_bind()
    inspector = sa.inspect(connection)
    table_exists = 'users' in inspector.get_table_names()
    
    if not table_exists:
        # Если таблицы нет, создаем её с нужными полями
        op.create_table('users',
            sa.Column('id', sa.UUID(), nullable=False),
            sa.Column('device_id', sa.String(), nullable=False),
            sa.Column('is_blocked', sa.Boolean(), nullable=False, server_default=sa.text('false')),
            sa.Column('mac_address', sa.String(), nullable=True),
            sa.Column('created_at', sa.DateTime(), server_default=sa.text("TIMEZONE('utc', now())"), nullable=False),
            sa.PrimaryKeyConstraint('id'),
            sa.UniqueConstraint('device_id', name='users_device_id_key')
        )
    else:
        # Если таблица существует, добавляем недостающие поля
        columns = [col['name'] for col in inspector.get_columns('users')]
        
        if 'device_id' not in columns:
            # Добавляем device_id как nullable сначала
            op.add_column('users', sa.Column('device_id', sa.String(), nullable=True))
            
            # Заполняем device_id для существующих записей (если есть)
            op.execute("""
                UPDATE users 
                SET device_id = gen_random_uuid()::text 
                WHERE device_id IS NULL
            """)
            
            # Делаем device_id NOT NULL и добавляем unique constraint
            op.alter_column('users', 'device_id',
                           existing_type=sa.String(),
                           nullable=False)
            op.create_unique_constraint('users_device_id_key', 'users', ['device_id'])
        
        if 'is_blocked' not in columns:
            # Добавляем is_blocked с default значением False
            op.add_column('users', sa.Column('is_blocked', sa.Boolean(), nullable=False, server_default=sa.text('false')))
        
        # Изменяем mac_address на nullable (если еще не nullable)
        mac_address_col = next((col for col in inspector.get_columns('users') if col['name'] == 'mac_address'), None)
        if mac_address_col and not mac_address_col.get('nullable', True):
            op.alter_column('users', 'mac_address',
                           existing_type=sa.String(),
                           nullable=True)


def downgrade() -> None:
    """Downgrade schema."""
    # Удаляем is_blocked
    op.drop_column('users', 'is_blocked')
    
    # Удаляем unique constraint и колонку device_id
    op.drop_constraint('users_device_id_key', 'users', type_='unique')
    op.drop_column('users', 'device_id')

