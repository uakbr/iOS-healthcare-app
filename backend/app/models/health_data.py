from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from .user import Base


class HealthData(Base):
    __tablename__ = "health_data"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    data_type = Column(String)  # e.g., "blood_pressure", "heart_rate"
    value = Column(Float)
    timestamp = Column(DateTime)
    
    user = relationship("User", back_populates="health_data")