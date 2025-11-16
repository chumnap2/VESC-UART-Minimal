import socket
import threading
import sys
import time

HOST = "127.0.0.1"
PORT = 9001

# --- Safe printing (no conflict with input) ---
print_lock = threading.Lock()

def safe_print(*args, **kwargs):
    with print_lock:
        sys.stdout.write("\r")         # return to line start
        sys.stdout.flush()
        print(*args, **kwargs)
        print("> ", end="", flush=True)  # redraw stable prompt


# --- Connect to Julia ---
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))
safe_print("✅ Connected to Julia bridge at 127.0.0.1:9001")
safe_print("💻 Commands: enable, disable, speed <value>, stop")


# --- Telemetry listener thread ---
def telemetry_listener():
    while True:
        try:
            data = s.recv(1024).decode().strip()
            if not data:
                return
            if data.startswith("T:"):
                # Julia telemetry: "T:pos,vel"
                _, payload = data.split(":")
                pos, vel = payload.split(",")
                safe_print(f"📊 Telemetry → Position: {pos}, Velocity: {vel}")
        except:
            return


threading.Thread(target=telemetry_listener, daemon=True).start()


# --- Input loop (stable prompt) ---
while True:
    try:
        cmd = input("> ").strip()

        if cmd == "exit":
            break
        if not cmd:
            continue

        s.sendall((cmd + "\n").encode())

    except KeyboardInterrupt:
        break

s.close()
