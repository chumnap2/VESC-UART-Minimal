import logging
import time
from pyvesc.VESC import VESC  # Use VESC class directly

SERIAL_PORT = "/dev/ttyACM1"
RECONNECT_DELAY = 2

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")

def open_vesc():
    try:
        vesc = VESC(SERIAL_PORT)  # Pass string port
        logging.info("Serial port opened successfully.")
        return vesc
    except Exception as e:
        logging.error(f"Error opening serial port: {e}")
        return None

def safe_spin(vesc, duration=2.0, steps=20):
    """Ramp motor up and down safely."""
    if not vesc:
        return

    try:
        logging.info("Starting safe motor spin ramp...")
        for i in range(steps):
            duty = i / steps * 0.1  # small duty cycle
            vesc.set_duty_cycle(duty)
            time.sleep(duration / steps)

        for i in reversed(range(steps)):
            duty = i / steps * 0.1
            vesc.set_duty_cycle(duty)
            time.sleep(duration / steps)

        logging.info("Spin complete. Stopping motor...")
        vesc.set_duty_cycle(0.0)
    except AttributeError as e:
        logging.error(f"VESC method not available: {e}")

def main():
    while True:
        vesc = open_vesc()
        if vesc:
            safe_spin(vesc)
            time.sleep(1)
        else:
            logging.info(f"Reconnect in {RECONNECT_DELAY}s...")
            time.sleep(RECONNECT_DELAY)

if __name__ == "__main__":
    main()
