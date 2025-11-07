#include <iostream>
#include <string>

// ------------------- HardwareInterface -------------------
class HardwareInterface {
public:
    HardwareInterface() {}
    void connect(const std::string& port) {
        std::cout << "[HAL] Connecting to hardware at port: " << port << std::endl;
        connected = true;
    }
    void setMotorSpeed(float speed) {
        if(connected) {
            std::cout << "[HAL] Setting motor speed to " << speed << std::endl;
        }
    }
    void enableMotor(bool enable) {
        if(connected) {
            std::cout << "[HAL] Motor " << (enable ? "enabled" : "disabled") << std::endl;
        }
    }
    float readPosition() {
        return position += 0.1f; // mock sensor data
    }
    float readVelocity() {
        return velocity;
    }

private:
    bool connected = false;
    float position = 0.0f;
    float velocity = 1.0f;
};

// ------------------- MotorController -------------------
class MotorController {
public:
    MotorController(HardwareInterface* hal) : hal(hal), enabled(false), speed(0) {}

    void init(const std::string& port) {
        hal->connect(port);
    }

    void setSpeed(float s) {
        speed = s;
        hal->setMotorSpeed(speed);
    }

    void setEnabled(bool e) {
        enabled = e;
        hal->enableMotor(enabled);
    }

    void update() {
        position = hal->readPosition();
        velocity = hal->readVelocity();
    }

    float getPosition() const { return position; }
    float getVelocity() const { return velocity; }

private:
    HardwareInterface* hal;
    bool enabled;
    float speed;
    float position;
    float velocity;
};

// ------------------- Main Test -------------------
int main() {
    HardwareInterface hal;
    MotorController controller(&hal);

    controller.init("/dev/ttyUSB0");

    controller.setEnabled(true);
    controller.setSpeed(1.5f);

    for (int i = 0; i < 10; i++) {
        controller.update();
        std::cout << "[Telemetry] Position: " << controller.getPosition()
                  << " Velocity: " << controller.getVelocity() << std::endl;
    }

    controller.setEnabled(false);
    return 0;
}
