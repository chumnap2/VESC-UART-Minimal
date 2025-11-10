#!/bin/bash
# setup_and_run_vesc_ramp.sh
# Full autonomous VESC simulation with acceleration-limited RPM response

set -e
set -x  # Show each command

AUTHOR="Chumnap Thach"
DATE="$(date +%Y-%m-%d)"
DESCRIPTION="This script will:
- Create project directories.
- Generate stub files (led.hpp, uart.hpp, thread.hpp, main.cpp).
- Prepend author/date/program description headers automatically to all stubs.
- Generate CMakeLists.txt.
- Build and run the ramped VESC simulation."

# -------------------------
# Project directories
mkdir -p include src build_vesc_ramp

# -------------------------
# Stub files

# LED
cat > include/led.hpp <<'EOL'
#pragma once
#include <iostream>
#include <string>
class LED {
    std::string name;
    bool state;
public:
    LED(const std::string& n = "LED") : name(n), state(false) {}
    static void init() { std::cout << "[LED] init\n"; }
    void on()  { state = true;  std::cout << "[LED] " << name << " ON\n"; }
    void off() { state = false; std::cout << "[LED] " << name << " OFF\n"; }
};
EOL

# UART
cat > include/uart.hpp <<'EOL'
#pragma once
#include <iostream>
#include <string>
class UART {
    std::string name;
public:
    UART(const std::string& n = "UART") : name(n) {}
    static void init() { std::cout << "[UART] init\n"; }
    void send(const std::string &msg) { std::cout << "[UART] " << name << " TX: " << msg << "\n"; }
    void receive(const std::string &msg) { std::cout << "[UART] " << name << " RX: " << msg << "\n"; }
};
EOL

# Thread stub
cat > include/thread.hpp <<'EOL'
#pragma once
#include <thread>
#include <functional>
class Thread {
    std::thread t;
public:
    Thread(std::function<void()> func) : t(func) {}
    ~Thread() { if (t.joinable()) t.join(); }
};
EOL

# Main
cat > src/main.cpp <<'EOL'
#include "led.hpp"
#include "uart.hpp"
#include "thread.hpp"
#include <chrono>
#include <thread>
#include <atomic>
#include <iostream>
#include <csignal>

std::atomic<int> targetRPM{0};
std::atomic<int> currentRPM{0};
std::atomic<bool> stopFlag{false};

void vescThread(UART* uart, LED* statusLED) {
    while (!stopFlag.load()) {
        int rpm = currentRPM.load();
        int tgt = targetRPM.load();
        if (rpm < tgt) rpm += 50;
        else if (rpm > tgt) rpm -= 50;
        currentRPM.store(rpm);

        uart->receive("RPM:" + std::to_string(rpm));
        if (rpm % 100 == 0) statusLED->on();
        else statusLED->off();
        std::this_thread::sleep_for(std::chrono::milliseconds(200));
    }
}

int main() {
    LED::init();
    UART::init();

    LED statusLED("StatusLED");
    UART vescUart("VESC_UART");

    Thread t([&](){ vescThread(&vescUart, &statusLED); });

    // Trap Ctrl+C
    std::signal(SIGINT, [](int){
        std::cout << "\n[INFO] Ctrl+C received. Stopping simulation...\n";
        stopFlag.store(true);
    });

    // Ramp up loop
    for (int rpm = 100; rpm <= 500; rpm += 100) {
        if (stopFlag.load()) break;
        targetRPM.store(rpm);
        vescUart.send("SetRPM:" + std::to_string(rpm));
        std::this_thread::sleep_for(std::chrono::seconds(1));
        if (stopFlag.load()) break;
        vescUart.send("GetRPM");
    }

    // Ramp down on exit
    std::cout << "[INFO] Ramping down motor...\n";
    while (currentRPM.load() > 0 && !stopFlag.load()) {
        int rpm = currentRPM.load() - 50;
        if (rpm < 0) rpm = 0;
        targetRPM.store(rpm);
        vescUart.send("SetRPM:" + std::to_string(rpm));
        std::this_thread::sleep_for(std::chrono::milliseconds(200));
    }

    std::cout << "[INFO] Motor stopped. Last RPM: " << currentRPM.load() << "\n";
    return 0;
}
EOL

# -------------------------
# CMakeLists.txt
cat > CMakeLists.txt <<'EOL'
cmake_minimum_required(VERSION 3.10)
project(minimal_vesc_ramp)
set(CMAKE_CXX_STANDARD 17)
add_executable(minimal_vesc_ramp src/main.cpp)
EOL

# -------------------------
# Add headers to all stub files
for FILE in src/*.cpp include/*.hpp; do
    [ -f "$FILE" ] || continue
    if ! grep -q "Author :" "$FILE"; then
        TMP_FILE="${FILE}.tmp"
        cat > "$TMP_FILE" <<EOF
/*
 * Author      : $AUTHOR
 * Date        : $DATE
 * Description : $DESCRIPTION
 * File        : $(basename "$FILE")
 */
EOF
        cat "$FILE" >> "$TMP_FILE"
        mv "$TMP_FILE" "$FILE"
    fi
done

# -------------------------
# Build
mkdir -p build_vesc_ramp
cd build_vesc_ramp
cmake ..
make -j$(nproc)

# -------------------------
# Run
./minimal_vesc_ramp
