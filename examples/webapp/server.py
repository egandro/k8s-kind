import http.server
import socketserver
import psycopg2
from http import HTTPStatus

web_port=3000
conn = None

def get_pg_version() -> str:
    global conn
    pg_version = "unknown"
    try:
        if conn is None:
            # https://www.postgresqltutorial.com/postgresql-python/connect/
            conn = psycopg2.connect(
                    host="postgres",
                    dbname="appdb",
                    user="appuser",
                    port="5432",
                    password="secret"
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
    return pg_version

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(HTTPStatus.OK)
        self.end_headers()
        self.wfile.write(b'Hello world: ')
        self.wfile.write(get_pg_version().encode())

httpd = socketserver.TCPServer(('', web_port), Handler)
httpd.serve_forever()