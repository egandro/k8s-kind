import http.server
import socketserver
from http import HTTPStatus

port=3000

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(HTTPStatus.OK)
        self.end_headers()
        self.wfile.write(b'Hello world')

httpd = socketserver.TCPServer(('', port), Handler)
httpd.serve_forever()