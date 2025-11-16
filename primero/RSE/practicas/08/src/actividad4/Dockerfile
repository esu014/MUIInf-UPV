# Dockerfile 
FROM alpine:latest

RUN apk update && apk add --no-cache python3 py3-pip

RUN pip install paho-mqtt --break-system-packages

WORKDIR /app

COPY sisub.py /app/

CMD ["python3", "sisub.py"]