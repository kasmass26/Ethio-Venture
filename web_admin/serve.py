#!/usr/bin/env python3
import http.server
import socketserver
import os
import webbrowser

PORT = 8085
DIRECTORY = os.path.dirname(os.path.abspath(__file__))

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

print(f"🚀 Launching Ethio-Venture Web Admin Panel...")
print(f"🌐 Server running at: http://localhost:{PORT}")
print(f"📂 Serving directory: {DIRECTORY}")

socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Web Admin server stopped.")
