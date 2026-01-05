from pydantic import BaseModel, EmailStr

class SChangePassword(BaseModel):
    old_password: str
    new_password: str
    verify_new_password: str

class SForgotPassword(BaseModel):
    email: EmailStr

class SVerifyCode(BaseModel):
    email: EmailStr
    code: int