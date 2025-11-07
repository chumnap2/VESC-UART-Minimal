#include <iostream>

// ------------------- MotorController -------------------
class MotorController {
public:
    MotorController() : speed(0), enabled(false), position(0), velocity(0) {}
    void setSpeed(float s) { speed = s; }
    void setEnabled(bool e) { enabled = e; }
    float getPosition() { return position; }
    float getVelocity() { return velocity; }
    void update(float dt) {
        if(enabled) {
            velocity = speed;
            position += velocity * dt;
        } else {
            velocity = 0;
        }
    }
private:
    float speed;
    bool enabled;
    float position;
    float velocity;
};

// ------------------- MotorBridge -------------------
class MotorBridge {
public:
    MotorBridge(MotorController* mc) : controller(mc), lastSpeed(0), enabled(false) {}
    void CmdSpeed_handler(float speed) {
        lastSpeed = speed;
        if(controller) controller->setSpeed(speed);
    }
    void CmdEnable_handler(bool e) {
        enabled = e;
        if(controller) controller->setEnabled(e);
    }
    void sendFeedback() {
        if(controller) {
            std::cout << "[Telemetry] Position: " << controller->getPosition()
                      << " Velocity: " << controller->getVelocity() << std::endl;
        }
    }
private:
    MotorController* controller;
    float lastSpeed;
    bool enabled;
};

// ------------------- TestCommandGenerator -------------------
class TestCommandGenerator {
public:
    TestCommandGenerator(MotorBridge* mb) : bridge(mb) {}
    void sendCommand(float speed, bool enable) {
        bridge->CmdSpeed_handler(speed);
        bridge->CmdEnable_handler(enable);
    }
private:
    MotorBridge* bridge;
};

// ------------------- Main -------------------
int main() {
    MotorController controller;
    MotorBridge bridge(&controller);
    TestCommandGenerator generator(&bridge);

    float dt = 0.1f;
    float tmax = 10.0f;

    for(float t=0; t<=tmax; t+=dt) {
        float speed = (t < 5.0f) ? 1.0f : 2.0f;
        bool enable = true;

        generator.sendCommand(speed, enable);

        controller.update(dt);
        bridge.sendFeedback();
    }

    return 0;
}
