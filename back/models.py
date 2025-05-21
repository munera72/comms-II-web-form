from sqlalchemy import Column, Integer, String, Boolean
from database import Base

class Attendance(Base):
    __tablename__ = "event_attendance"
    
    id = Column(Integer, primary_key=True, index=True)
    fullname = Column(String(255), nullable=False)
    email = Column(String(255), nullable=False)
    gender = Column(String(10), nullable=False)
    age = Column(Integer, nullable=False)
    is_student = Column(Boolean, nullable=False)