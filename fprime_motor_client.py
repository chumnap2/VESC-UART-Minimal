import socket
import json
import time
import threading

class FprimeMotorClient:
    def __init__(self, host="127.0.0.1", port=9000):
        self.host = host
        self.port = port
        self.sock = None
        self.running = True

    def connect(self):
        self.sock = socket.socket()
        self.sock.connect((self.host, self.port))
        print(f"✅ Connected to Julia bridge at {self.host}:{self.port}")

    def send_command(self, cmd, value=None):
        msg = {"cmd": cmd}
        if value is not None:
            msg["value"] = value
        self.sock.sendall(json.dumps(msg).encode() + b"\n")

    def enable_motor(self):
        self.send_command("ENABLE")

    def disable_motor(self):
        self.send_command("DISABLE")

    def set_speed(self, speed):
        self.send_command("SPEED", speed)

    def receive_telemetry(self):
        while self.running:
            try:
                data = self.sock.recv(1024).decode().strip()
                if data:
                    for line in data.split("\n"):
                        tel = json.loads(line)
                        pos = tel.get("pos", 0.0)
                        vel = tel.get("vel", 0.0)
                        print(f"📊 Telemetry → Position: {pos:.2f}, Velocity: {vel:.2f}")
            except Exception as e:
                print("⚠️ Telemetry error:", e)
            time.sleep(0.5)

    def start(self):
        # Start telemetry in a separate thread
        t = threading.Thread(target=self.receive_telemetry, daemon=True)
        t.start()

        print("💻 Interactive REPL started. Commands: enable, disable, speed <value>, stop")
        try:
            while True:
                cmd = input("> ").strip().lower()
                if cmd == "enable":
                    self.enable_motor()
                elif cmd == "disable" or cmd == "stop":
                    self.disable_motor()
                elif cmd.startswith("speed"):
                    parts = cmd.split()
                    if len(parts) == 2:
                        try:
                            speed = float(parts[1])
                            self.set_speed(speed)
                        except ValueError:
                            print("❌ Invalid speed value")
                    else:
                        print("❌ Usage: speed <value>")
                elif cmd in ("exit", "quit"):
                    print("🛑 Exiting...")
                    break
                else:
                    print("❌ Unknown command")
        finally:
            self.running = False
            self.disable_motor()
            self.sock.close()
            print("✅ Motor client disconnected.")
