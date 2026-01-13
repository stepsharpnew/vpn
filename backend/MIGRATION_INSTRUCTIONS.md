# Инструкция по применению миграций

## Проблема

Ошибка: `relation "users" does not exist` - таблица users не существует в базе данных.

## Решение

Нужно применить все миграции к базе данных. Выполните следующие команды:

### Шаг 1: Убедитесь, что база данных запущена

Проверьте, что PostgreSQL запущен (через docker-compose или напрямую).

### Шаг 2: Примените миграции

В терминале перейдите в папку `backend` и выполните:

```bash
cd backend
uv run alembic upgrade head
```

Если команда `uv run alembic` не работает, попробуйте:

```bash
# Активируйте виртуальное окружение
.venv\Scripts\activate  # Windows
# или
source .venv/bin/activate  # Linux/Mac

# Затем выполните
alembic upgrade head
```

### Шаг 3: Проверьте результат

После применения миграций таблица `users` должна быть создана со следующими полями:

- `id` (UUID, primary key)
- `device_id` (String, unique, not null)
- `is_blocked` (Boolean, default false)
- `mac_address` (String, nullable)
- `created_at` (DateTime)

### Шаг 4: Перезапустите бэкенд

После применения миграций перезапустите бэкенд сервер:

```bash
uv run uvicorn app.main:app --host=0.0.0.0 --port=8000 --reload
```

## Если миграции не применяются

Если возникают ошибки при применении миграций:

1. **Проверьте подключение к базе данных** - убедитесь, что PostgreSQL доступен
2. **Проверьте настройки в `.env`** - должны быть правильные DB_HOST, DB_PORT, DB_USER, DB_PASS, DB_NAME
3. **Проверьте логи** - посмотрите на ошибки в выводе команды `alembic upgrade head`

## Альтернативный способ (если миграции не работают)

Если миграции не работают, можно создать таблицу вручную через SQL:

```sql
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id VARCHAR NOT NULL UNIQUE,
    is_blocked BOOLEAN NOT NULL DEFAULT false,
    mac_address VARCHAR,
    created_at TIMESTAMP NOT NULL DEFAULT TIMEZONE('utc', now())
);
```

Но рекомендуется использовать миграции для управления схемой базы данных.
