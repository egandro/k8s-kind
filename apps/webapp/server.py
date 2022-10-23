import http.server
import socketserver
import psycopg2
import socket

from http import HTTPStatus
from os import getenv

myHostName = socket.gethostname()

web_port=getenv("WEB_PORT", 3000)
conn = None

POSTGRES_HOST = getenv("POSTGRES_HOST")
POSTGRES_PORT = getenv("POSTGRES_PORT", 5432)
POSTGRES_DB = getenv("POSTGRES_DB")
POSTGRES_USER = getenv("POSTGRES_USER")
POSTGRES_PASSWORD = getenv("POSTGRES_PASSWORD")

def get_pg_version() -> str:
    global conn
    pg_version = "unknown"
    try:
        if conn is None:
            # https://www.postgresqltutorial.com/postgresql-python/connect/
            conn = psycopg2.connect(
                    host=POSTGRES_HOST,
                    port=POSTGRES_PORT,
                    dbname=POSTGRES_DB,
                    user=POSTGRES_USER,
                    password=POSTGRES_PASSWORD
                )
        if conn is None:
            print(f"connection failed")
        else:
            print("connected")
        cur = conn.cursor()
        cur.execute('SELECT version()')
        version = cur.fetchone()
        pg_version = version[0]
        print(f"pg_version {pg_version}")
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        pg_version = "error: " + str(error)
        conn = None
    return pg_version

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(HTTPStatus.OK)
        self.end_headers()
        self.wfile.write(b'Hello world: ')
        self.wfile.write(b' hostname: (')
        self.wfile.write(myHostName.encode())
        self.wfile.write(b') ')
        self.wfile.write(get_pg_version().encode())

httpd = socketserver.TCPServer(('', web_port), Handler)
httpd.serve_forever()