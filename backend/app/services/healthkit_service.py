import logging
from typing import List, Dict
import healthkit
from ..models.health_data import HealthData

logger = logging.getLogger(__name__)


class HealthKitService:
    def __init__(self):
        self.healthkit = healthkit.HealthKit()
        self.supported_types = HealthData.Config.supported_types
        
    async def sync_health_data(self, user_id: int) -> List[Dict]:
        """Sync comprehensive health data from HealthKit"""
        synced_data = []
        
        # Core metrics
        basic_metrics = await self._fetch_basic_metrics(user_id)
        synced_data.extend(basic_metrics)
        
        # Advanced metrics
        advanced_metrics = await self._fetch_advanced_metrics(user_id)
        synced_data.extend(advanced_metrics)
        
        # Environmental data
        environmental_data = await self._fetch_environmental_data(user_id)
        synced_data.extend(environmental_data)
        
        return synced_data

    async def _fetch_basic_metrics(self, user_id: int) -> List[Dict]:
        """Fetch vital signs and basic health metrics"""
        metrics = [
            "heart_rate", "blood_pressure", "respiratory_rate",
            "blood_oxygen", "body_temperature", "blood_glucose"
        ]
        return await self._batch_fetch_data(metrics, user_id)

    async def _fetch_advanced_metrics(self, user_id: int) -> List[Dict]:
        """Fetch advanced health metrics"""
        metrics = [
            "heart_rate_variability", "vo2_max", "electrocardiogram",
            "galvanic_skin_response", "blood_alcohol_content"
        ]
        return await self._batch_fetch_data(metrics, user_id)

    async def _fetch_environmental_data(self, user_id: int) -> List[Dict]:
        """Fetch environmental context data"""
        metrics = [
            "ambient_temperature", "humidity", "air_quality",
            "noise_level", "uv_exposure", "atmospheric_pressure"
        ]
        return await self._batch_fetch_data(metrics, user_id)