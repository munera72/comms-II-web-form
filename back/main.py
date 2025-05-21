from fastapi import FastAPI, Depends
from pydantic import BaseModel
from database import engine, SessionLocal
from typing import Annotated
from sqlalchemy.orm import Session
import models
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

origins = [
"*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
models.Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

db_dependency = Annotated[Session, Depends(get_db)]


class Answer(BaseModel):
    fullname: str
    email: str
    age: int
    gender: str
    is_student: bool


    
@app.post("/attendance")
async def mark_attendance(answer: Answer, db: db_dependency):
    db_attendance = models.Attendance(
        fullname=answer.fullname,
        email=answer.email,
        age=answer.age,
        gender=answer.gender,
        is_student=answer.is_student
    )
    db.add(db_attendance)
    db.commit()
    return {"message": "Attendance marked successfully!"}