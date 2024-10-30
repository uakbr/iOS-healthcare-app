from sqlalchemy import (
    Column, Integer, String, Float, DateTime, ForeignKey, JSON,
    Boolean, Text
)
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import ARRAY
from datetime import datetime
from enum import Enum as PyEnum
from .user import Base


class DataQuality(PyEnum):
    HIGH = "high"
    MEDIUM = "medium"
    LOW = "low"
    UNCERTAIN = "uncertain"


class HealthMetricType(PyEnum):
    VITAL = "vital"
    ACTIVITY = "activity"
    NUTRITION = "nutrition"
    SLEEP = "sleep"
    MENTAL = "mental"
    ENVIRONMENTAL = "environmental"


class HealthData(Base):
    __tablename__ = "health_data"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    data_type = Column(String)
    value = Column(Float)
    timestamp = Column(DateTime, default=datetime.utcnow)
    
    # Enhanced metadata
    metadata = Column(JSON, default={
        "device_info": {},
        "location": {},
        "environmental_factors": {},
        "confidence_score": 1.0,
        "data_quality": DataQuality.HIGH.value,
        "collection_method": "automatic"
    })
    
    # Source tracking
    source = Column(String)
    source_version = Column(String)
    device_id = Column(String)
    
    # Data quality and validation
    is_validated = Column(Boolean, default=False)
    quality_score = Column(Float, default=1.0)
    confidence_interval = Column(ARRAY(Float), default=[0.0, 0.0])
    
    # Contextual information
    context_tags = Column(ARRAY(String), default=[])
    notes = Column(Text)
    
    # Relationships
    user = relationship("User", back_populates="health_data")
    anomalies = relationship("HealthDataAnomaly", back_populates="health_data")
    
    class Config:
        supported_types = [
            # Vital Signs
            "heart_rate",
            "heart_rate_variability",
            "blood_pressure_systolic",
            "blood_pressure_diastolic",
            "respiratory_rate",
            "blood_oxygen",
            "body_temperature",
            "blood_glucose",
            "galvanic_skin_response",
            
            # Physical Metrics
            "weight",
            "body_fat_percentage",
            "lean_muscle_mass",
            "bone_density",
            "body_water_percentage",
            "waist_circumference",
            "bmi",
            
            # Activity Metrics
            "steps",
            "distance_walked",
            "floors_climbed",
            "active_minutes",
            "exercise_duration",
            "calories_burned",
            "metabolic_equivalent",
            "vo2_max",
            "recovery_time",
            "training_load",
            
            # Sleep Metrics
            "sleep_duration",
            "deep_sleep_duration",
            "rem_sleep_duration",
            "light_sleep_duration",
            "sleep_efficiency",
            "sleep_latency",
            "wake_episodes",
            "sleep_breathing_rate",
            "sleep_hrv",
            
            # Nutrition
            "calories_consumed",
            "protein_intake",
            "carbohydrate_intake",
            "fat_intake",
            "fiber_intake",
            "water_intake",
            "micronutrients",
            "meal_timing",
            "glycemic_response",
            
            # Mental Health
            "stress_level",
            "mood_score",
            "anxiety_level",
            "meditation_minutes",
            "cognitive_performance",
            "focus_duration",
            "emotional_state",
            "energy_level",
            
            # Environmental
            "ambient_temperature",
            "humidity",
            "air_quality",
            "noise_level",
            "light_exposure",
            "uv_exposure",
            "altitude",
            "atmospheric_pressure"
        ]
        
        metric_types = {
            "vital": [
                "heart_rate", "blood_pressure_systolic",
                "blood_pressure_diastolic", "respiratory_rate",
                "blood_oxygen", "body_temperature", "blood_glucose"
            ],
            "activity": [
                "steps", "distance_walked", "floors_climbed",
                "active_minutes", "exercise_duration", "calories_burned"
            ],
            "sleep": [
                "sleep_duration", "deep_sleep_duration",
                "rem_sleep_duration", "sleep_efficiency"
            ],
            "nutrition": [
                "calories_consumed", "protein_intake",
                "carbohydrate_intake", "fat_intake", "water_intake"
            ],
            "mental": [
                "stress_level", "mood_score", "anxiety_level",
                "meditation_minutes", "cognitive_performance"
            ],
            "environmental": [
                "ambient_temperature", "humidity", "air_quality",
                "noise_level", "light_exposure"
            ]
        }
        
        thresholds = {
            "heart_rate": {"min": 40, "max": 200, "unit": "bpm"},
            "blood_pressure_systolic": {
                "min": 70, "max": 190, "unit": "mmHg"
            },
            "blood_pressure_diastolic": {
                "min": 40, "max": 130, "unit": "mmHg"
            },
            "blood_oxygen": {"min": 80, "max": 100, "unit": "%"},
            "body_temperature": {"min": 35, "max": 42, "unit": "°C"},
            "steps": {"min": 0, "max": 100000, "unit": "steps"},
            "sleep_duration": {"min": 0, "max": 24, "unit": "hours"}
        }

    def validate_data(self) -> bool:
        """Validate the health data point against defined thresholds."""
        if self.data_type in self.Config.thresholds:
            threshold = self.Config.thresholds[self.data_type]
            if threshold["min"] <= self.value <= threshold["max"]:
                self.is_validated = True
                return True
        return False

    def get_metric_type(self) -> str:
        """Get the category of the health metric."""
        for metric_type, metrics in self.Config.metric_types.items():
            if self.data_type in metrics:
                return metric_type
        return "other"

    def to_dict(self) -> dict:
        """Convert the health data point to a dictionary with context."""
        return {
            "id": self.id,
            "type": self.data_type,
            "value": self.value,
            "timestamp": self.timestamp.isoformat(),
            "metric_type": self.get_metric_type(),
            "metadata": self.metadata,
            "quality": {
                "score": self.quality_score,
                "validated": self.is_validated,
                "confidence_interval": self.confidence_interval
            },
            "context": {
                "tags": self.context_tags,
                "notes": self.notes
            }
        }