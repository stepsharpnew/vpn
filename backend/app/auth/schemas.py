from pydantic import BaseModel, EmailStr

class SUserLogin(BaseModel):
    email: EmailStr
    password: str

class SUserRegister(BaseModel):
    email: EmailStr
    password: str

class SFirstTimeInitUser(BaseModel):
    device_id: str
    