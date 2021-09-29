FROM python:3.9-slim
COPY src/requirements.txt /app/
WORKDIR /app
RUN pip install -r requirements.txt
ADD src /app/
CMD [ "ddtrace-run", "python", "app.py" ]
EXPOSE 80