from pydantic import BaseModel
from typing import Optional

class ConnectRequest(BaseModel):
    device_id: str


