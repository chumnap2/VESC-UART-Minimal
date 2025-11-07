#pragma once
#include "MotorController.hpp"
#include "Fw/Comp/FwComponentBase.hpp"

namespace Motor {

class MotorBridge : public Fw::ComponentBase {
public:
    MotorBridge(const char* compName);
    void init(NATIVE_INT_TYPE queueDepth, NATIVE_INT_TYPE instance = 0);

    void CmdSpeed_handler(NATIVE_INT_TYPE portNum, float speed);
    void CmdEnable_handler(NATIVE_INT_TYPE portNum, bool enable);

    void sendPosition(float position);
    void sendVelocity(float velocity);

    void setMotorController(MotorController* controller);

private:
    float m_lastSpeed;
    bool m_enabled;
    MotorController* m_controller;
};

} // namespace Motor
