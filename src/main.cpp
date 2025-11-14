/*
 * Author      : Chumnap Thach
 * Date        : 2025-11-14
 * Description : This script will:
- Create project directories.
- Generate stub files (led.hpp, uart.hpp, thread.hpp, main.cpp).
- Prepend author/date/program description headers automatically to all stubs.
- Generate CMakeLists.txt.
- Build and run the ramped VESC simulation.
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
