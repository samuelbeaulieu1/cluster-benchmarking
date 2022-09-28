FROM python:3.8-alpine

ENV APP_URL ""

COPY ./requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip install -r requirements.txt

COPY app_test.py /app

ENTRYPOINT ["python"]

CMD ["app_test.py"]
