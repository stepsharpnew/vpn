from pydantic import BaseModel
from typing import Optional

class ConnectRequest(BaseModel):
    device_id: str

class VpnConfig(BaseModel):
    server_ip: str
    server_port: int
    username: str
    password: str
    dns: Optional[str] = None
    public_key: Optional[str] = None
    # Дополнительные поля для WireGuard/OpenVPN конфигурации
    config_data: Optional[dict] = None

