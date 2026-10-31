#!/usr/bin/env python3
"""Switch the OBS program scene over the built-in obs-websocket (v5) server.

Usage: obs_scene.py "<scene name>"
       obs_scene.py --list

Port and password are read from OBS's own websocket config, so nothing
secret lives in the dotfiles. Override with OBS_WS_PORT / OBS_WS_PASSWORD.
Standard library only.
"""
import base64
import hashlib
import json
import os
import socket
import struct
import sys

CONFIG_PATH = os.path.expanduser(
    "~/Library/Application Support/obs-studio/plugin_config/obs-websocket/config.json"
)


def load_settings():
    port, password = 4455, ""
    try:
        with open(CONFIG_PATH) as f:
            cfg = json.load(f)
        port = int(cfg.get("server_port", port))
        if cfg.get("auth_required", False):
            password = cfg.get("server_password", "")
    except (OSError, ValueError):
        pass
    port = int(os.environ.get("OBS_WS_PORT", port))
    password = os.environ.get("OBS_WS_PASSWORD", password)
    return port, password


def recv_exact(sock, n):
    buf = b""
    while len(buf) < n:
        chunk = sock.recv(n - len(buf))
        if not chunk:
            raise ConnectionError("OBS closed the connection")
        buf += chunk
    return buf


def send_json(sock, obj):
    payload = json.dumps(obj).encode()
    header = bytearray([0x81])
    n = len(payload)
    if n < 126:
        header.append(0x80 | n)
    elif n < 65536:
        header.append(0x80 | 126)
        header += struct.pack(">H", n)
    else:
        header.append(0x80 | 127)
        header += struct.pack(">Q", n)
    mask = os.urandom(4)
    masked = bytes(b ^ mask[i % 4] for i, b in enumerate(payload))
    sock.sendall(bytes(header) + mask + masked)


def recv_json(sock):
    message = b""
    while True:
        b1, b2 = recv_exact(sock, 2)
        opcode = b1 & 0x0F
        n = b2 & 0x7F
        if n == 126:
            n = struct.unpack(">H", recv_exact(sock, 2))[0]
        elif n == 127:
            n = struct.unpack(">Q", recv_exact(sock, 8))[0]
        mask = recv_exact(sock, 4) if b2 & 0x80 else None
        data = recv_exact(sock, n)
        if mask:
            data = bytes(b ^ mask[i % 4] for i, b in enumerate(data))
        if opcode == 0x8:
            raise ConnectionError("OBS closed the connection (auth failed?)")
        if opcode == 0x9:
            continue
        message += data
        if b1 & 0x80:
            return json.loads(message)


def connect(port, password):
    sock = socket.create_connection(("127.0.0.1", port), timeout=3)
    key = base64.b64encode(os.urandom(16)).decode()
    sock.sendall(
        (
            "GET / HTTP/1.1\r\n"
            f"Host: 127.0.0.1:{port}\r\n"
            "Upgrade: websocket\r\n"
            "Connection: Upgrade\r\n"
            f"Sec-WebSocket-Key: {key}\r\n"
            "Sec-WebSocket-Version: 13\r\n"
            "Sec-WebSocket-Protocol: obswebsocket.json\r\n\r\n"
        ).encode()
    )
    response = b""
    while b"\r\n\r\n" not in response:
        chunk = sock.recv(1024)
        if not chunk:
            raise ConnectionError("No handshake response from OBS")
        response += chunk
    if b" 101 " not in response.split(b"\r\n", 1)[0]:
        raise ConnectionError("WebSocket handshake rejected")

    hello = recv_json(sock)
    identify = {"rpcVersion": 1, "eventSubscriptions": 0}
    auth = hello.get("d", {}).get("authentication")
    if auth:
        secret = base64.b64encode(
            hashlib.sha256((password + auth["salt"]).encode()).digest()
        ).decode()
        identify["authentication"] = base64.b64encode(
            hashlib.sha256((secret + auth["challenge"]).encode()).digest()
        ).decode()
    send_json(sock, {"op": 1, "d": identify})
    reply = recv_json(sock)
    if reply.get("op") != 2:
        raise ConnectionError("OBS did not accept identification")
    return sock


def request(sock, request_type, data=None):
    send_json(
        sock,
        {
            "op": 6,
            "d": {
                "requestType": request_type,
                "requestId": request_type,
                "requestData": data or {},
            },
        },
    )
    while True:
        msg = recv_json(sock)
        if msg.get("op") == 7 and msg["d"].get("requestId") == request_type:
            status = msg["d"]["requestStatus"]
            if not status.get("result"):
                raise RuntimeError(status.get("comment", "request failed"))
            return msg["d"].get("responseData", {})


def main():
    if len(sys.argv) != 2:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    port, password = load_settings()
    try:
        sock = connect(port, password)
        if sys.argv[1] == "--list":
            for scene in reversed(request(sock, "GetSceneList")["scenes"]):
                print(scene["sceneName"])
        else:
            request(sock, "SetCurrentProgramScene", {"sceneName": sys.argv[1]})
        sock.close()
    except (OSError, ConnectionError, RuntimeError, ValueError) as e:
        print(f"obs_scene: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
