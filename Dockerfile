FROM python:3

WORKDIR /app
COPY ./bot/requirements.txt .
RUN pip install -r requirements.txt && mkdir /token
COPY ./bot/* .

ENTRYPOINT ["python"]
CMD ["main.py"]