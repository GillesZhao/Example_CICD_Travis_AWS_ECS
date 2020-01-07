FROM python:3.7-alpine AS app-python
ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
CMD ["python", "app.py"]

FROM redis:alpine AS app-redis
