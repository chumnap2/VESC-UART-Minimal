# Stage8MotorBridge

This project controls a VESC motor via a Julia TCP server and a Python client.
It uses **local, custom modules**:

- `pyvesc_working/` → custom tested pyvesc version
- F′ Stage8 components → local NASA F′ modules

**Do NOT replace with public pyvesc or F′ modules**, they may break compatibility.

## Setup

1. Activate Python virtual environment:
```bash
source fprime-venv/bin/activate

Set PYTHONPATH to include local pyvesc:
export PYTHONPATH=$PWD/pyvesc_working

Start Julia motor server:
julia MotorBridgeServer.jl

Start Python client:
python motor_client.py

Commands available in the client:
enable
set_speed <value>  # 0.0 to 1.0
disable
exit

Notes

All previous experiments are in archive/.

VERSION file contains the current project version.

Safe ramping is implemented for smooth motor startup.
