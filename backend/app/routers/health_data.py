from fastapi import APIRouter
from typing import Dict, List

router = APIRouter(prefix="/health-data", tags=["health"])


@router.get("/")
async def get_health_data() -> List[Dict]:
    # Mock data for testing
    return [
        {
            "type": "heart_rate",
            "value": 75,
            "timestamp": "2024-03-20T10:00:00"
        },
        {
            "type": "blood_pressure",
            "value": 120,
            "timestamp": "2024-03-20T10:00:00"
        }
    ]