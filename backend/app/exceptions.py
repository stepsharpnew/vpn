from fastapi import HTTPException, status

NoAccess = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail='Нет доступа',
)

NoTokenExeption = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail='Отсутсвует токен',
)

UncorectTokenExeption = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail='Неправильный токен',
)

ExpireTokenExeption = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail='Время действия токена истекло',
)

ExistingUserExeption = HTTPException(
    status_code=status.HTTP_409_CONFLICT,
    detail='Этот Email уже зарегестрирован',   
)

ErrorLoginException = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail='Неверный email или пароль',
)

VerifyOldPasswordException = HTTPException(
    status_code=status.HTTP_409_CONFLICT,
    detail='Старый пароль не совпадает',
)