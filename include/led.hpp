/*
 * Author      : Chumnap Thach
 * Date        : 2025-11-14
 * Description : This script will:
- Create project directories.
- Generate stub files (led.hpp, uart.hpp, thread.hpp, main.cpp).
- Prepend author/date/program description headers automatically to all stubs.
- Generate CMakeLists.txt.
- Build and run the ramped VESC simulation.
 * File        : led.hpp
 */
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
