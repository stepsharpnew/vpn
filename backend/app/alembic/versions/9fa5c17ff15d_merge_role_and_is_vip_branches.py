"""merge role and is_vip branches

Revision ID: 9fa5c17ff15d
Revises: 1a01c27e39b1, bde400b4a76c
Create Date: 2026-01-21 14:55:56.145641

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '9fa5c17ff15d'
down_revision: Union[str, Sequence[str], None] = ('1a01c27e39b1', 'bde400b4a76c')
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
