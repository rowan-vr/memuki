"""Serves build/web for the spike. Pass --isolate to send COOP/COEP headers.

Usage: python3 serve.py <port> <jitendex dir> [--isolate]
"""
import functools
import http.server
import os
import sys

port, dict_dir = int(sys.argv[1]), sys.argv[2]
isolate = "--isolate" in sys.argv
root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "web")


class Handler(http.server.SimpleHTTPRequestHandler):
    def translate_path(self, path):
        if path.startswith("/dict/"):
            return os.path.join(dict_dir, os.path.basename(path.split("?")[0]))
        return super().translate_path(path)

    def end_headers(self):
        if isolate:
            self.send_header("Cross-Origin-Opener-Policy", "same-origin")
            self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, *args):
        pass


http.server.ThreadingHTTPServer(
    ("127.0.0.1", port), functools.partial(Handler, directory=root)
).serve_forever()
