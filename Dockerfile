FROM python:3

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt && mkdir /token
COPY . .

ENTRYPOINT ["python", "main.py"]