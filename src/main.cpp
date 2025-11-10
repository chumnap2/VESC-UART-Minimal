/*
 * Author      : Chumnap Thach
 * Date        : 2025-09-30
 * Description : This project simulates a ramped VESC motor controller:
- create project directories
- generate stub files (led, uart, thread, main)
- prepend author/date/program description headers automatically
- generate CMakeLists.txt
- build and run ramp simulation (Ctrl+C triggers smooth ramp-down)
 * File        : main.cpp
 */
#include "led.hpp"
#include "uart.hpp"
#include "thread.hpp"

#include <chrono>
#include <thread>
#include <atomic>
#include <iostream>
#include <csignal>
#include <string>

std::atomic<int> targetRPM{0};
std::atomic<int> currentRPM{0};
std::atomic<bool> stopFlag{false};

// Plain function signal handler (required by signal())
void handle_sigint(int /*signum*/) {
    stopFlag.store(true);
    std::cout << "\n[INFO] Ctrl+C received. Stopping simulation...\n";
}

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

    // On stopFlag set, ramp-down is handled by main loop; this thread just exits.
}

int main() {
    // Register signal handler
    std::signal(SIGINT, handle_sigint);

    LED::init();
    UART::init();

    LED statusLED("StatusLED");
    UART vescUart("VESC_UART");

    // Start vesc simulation thread
    Thread t([&](){ vescThread(&vescUart, &statusLED); });

    // Ramp-up sequence; check stopFlag between steps for responsiveness
    for (int rpm = 100; rpm <= 500; rpm += 100) {
        if (stopFlag.load()) break;
        targetRPM.store(rpm);
        vescUart.send("SetRPM:" + std::to_string(rpm));

        // sleep in small increments so Ctrl+C is responsive
        for (int i = 0; i < 10 && !stopFlag.load(); ++i) {
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
        }

        if (stopFlag.load()) break;
        vescUart.send("GetRPM");
    }

    // If stopFlag set (Ctrl+C) or after ramp-up, do smooth ramp-down
    std::cout << "[INFO] Ramping down motor...\n";
    while (currentRPM.load() > 0) {
        int rpm = currentRPM.load() - 50;
        if (rpm < 0) rpm = 0;
        targetRPM.store(rpm);
        vescUart.send("SetRPM:" + std::to_string(rpm));
        std::this_thread::sleep_for(std::chrono::milliseconds(200));
    }

    std::cout << "[INFO] Motor stopped. Last RPM: " << currentRPM.load() << "\n";
    return 0;
}
