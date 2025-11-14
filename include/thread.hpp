/*
 * Author      : Chumnap Thach
 * Date        : 2025-11-14
 * Description : This script will:
- Create project directories.
- Generate stub files (led.hpp, uart.hpp, thread.hpp, main.cpp).
- Prepend author/date/program description headers automatically to all stubs.
- Generate CMakeLists.txt.
- Build and run the ramped VESC simulation.
 * File        : thread.hpp
 */
#pragma once
#include <thread>
#include <functional>
class Thread {
    std::thread t;
public:
    Thread(std::function<void()> func) : t(func) {}
    ~Thread() { if (t.joinable()) t.join(); }
};
