/*
 * Author      : Chumnap Thach
 * Date        : 2025-11-14
 * Description : This script will:
- Create project directories.
- Generate stub files (led.hpp, uart.hpp, thread.hpp, main.cpp).
- Prepend author/date/program description headers automatically to all stubs.
- Generate CMakeLists.txt.
- Build and run the ramped VESC simulation.
 * File        : uart.hpp
 */
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
