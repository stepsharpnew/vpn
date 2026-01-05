from fastapi import Request, Depends, Response
from jose import jwt, JWTError
from datetime import datetime, timezone

from app.config import settings
from app.auth.auth import create_access_token
from app.auth.dao import RefreshTokensDAO
from app.users.dao import UsersDAO, UsersVipDAO
from app.exceptions import NoTokenExeption, UncorectTokenExeption, ExpireTokenExeption

# def get_access_token(request: Request):
#     try:
#         token = request.cookies['access_token']
#     except:
#         raise NoTokenExeption
#     return token


# def get_refresh_token(request: Request):
#     try:
#         token = request.cookies['refresh_token']
#     except:
#         raise NoTokenExeption
#     return token

async def get_current_user(response: Response,
                           request: Request,
                           access_token: str):
                        #    refresh_token: str = Depends(get_refresh_token)):
    try:
        payload = jwt.decode(
            access_token, settings.SECRET_WORD, settings.HASH_ALGORITHM, options={"verify_exp": False}
        )
    except JWTError as e:
        raise UncorectTokenExeption
    
    user_id: str = payload['sub']
    if not user_id:
        raise UncorectTokenExeption
    
    expire: str = payload['exp']
    if (not expire) or (int(expire) < datetime.now(timezone.utc).timestamp()):
        # user_agent = request.headers.get('User-Agent')
        # refresh_token_data = await RefreshTokensDAO.find_refresh_token(token=refresh_token, user_id=user_id, user_agent=user_agent)
        
        # if refresh_token_data:
        #     if int(refresh_token_data.expires_at) > datetime.now(timezone.utc).timestamp():
        #         access_token = create_access_token({'sub': user_id})
        #         response.set_cookie('access_token', access_token, httponly=True)
        #     else:
        #         raise ExpireTokenExeption
        # else:
        #     raise ExpireTokenExeption
        raise ExpireTokenExeption
    user = await UsersVipDAO.find_by_id(user_id)
    if not user:
        raise UncorectTokenExeption
    
    user_dict = {'id': user.id,
                 'email': user.email}

    return user_dict