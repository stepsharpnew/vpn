# backend/app/utils/awg_api_client.py
import httpx
from typing import Dict, Optional

class AWGAPIClient:
    """Клиент для работы с AmneziaWG Web UI API"""
    
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.client = httpx.AsyncClient(base_url=base_url)
    
    async def create_peer(self, server_ip: str, name: str) -> Dict:
        """Создает нового peer через API"""
        response = await self.client.post(
            f"/api/servers/{server_ip}/clients",
            json={"name": name}
        )
        response.raise_for_status()
        return response.json()
    
    async def delete_peer(self, peer_id: str, interface: str = "awg0") -> bool:
        """Удаляет peer через API"""
        response = await self.client.delete(
            f"/api/peers/{peer_id}",
            params={"interface": interface}
        )
        return response.status_code == 200
    
    async def get_peer_config(self, peer_id: str) -> str:
        """Получает конфигурацию для клиента"""
        response = await self.client.get(f"/api/peers/{peer_id}/config")
        response.raise_for_status()
        return response.text