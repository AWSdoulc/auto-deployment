FROM python:3.10-slim
WORKDIR /my-python-app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
