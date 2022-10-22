FROM python:3.10.8-slim

#RUN apt-get update \
#  && apt-get install -y curl \
#  && rm -rf /var/lib/apt/lists/*

RUN pip3 install psycopg2-binary

WORKDIR /app
COPY server.py .

EXPOSE 3000
CMD python server.py
