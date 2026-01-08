from pydantic import BaseModel, EmailStr

class SUserLogin(BaseModel):
    email: EmailStr
    password: str

class SUserRegister(BaseModel):
    email: EmailStr
    password: str

class SRefreshToken(BaseModel):
    refresh_token: str