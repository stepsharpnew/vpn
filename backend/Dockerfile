FROM python:3.12

RUN mkdir /backend

WORKDIR /backend

RUN pip install uv

COPY pyproject.toml .
COPY uv.lock .

RUN uv sync

COPY . .

RUN chmod a+x /backend/docker/*.sh

CMD ["uv", "run", "uvicorn", "app.main:app", "--host=0.0.0.0", "--port=8000"]