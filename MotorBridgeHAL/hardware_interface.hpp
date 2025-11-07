#pragma once
#include <string>
#include <iostream>

class HardwareInterface {
private:
    bool connected = false;

public:
    HardwareInterface() {}

    void connect(const std::string& port) {
        std::cout << "[HAL] Connecting to hardware at port: " << port << std::endl;
        connected = true;
    }

    void setMotorSpeed(float speed) {
        if (connected) {
            std::cout << "[HAL] Setting motor speed to " << speed << std::endl;
        }
    }

    void enableMotor(bool enable) {
        if (connected) {
            std::cout << "[HAL] Motor " << (enable ? "enabled" : "disabled") << std::endl;
        }
    }
};
