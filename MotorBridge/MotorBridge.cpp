#include "MotorBridge.hpp"

namespace Motor {

MotorBridge::MotorBridge(const char* compName) : Fw::ComponentBase(compName),
    m_lastSpeed(0.0f), m_enabled(false), m_controller(nullptr) {}

void MotorBridge::init(NATIVE_INT_TYPE queueDepth, NATIVE_INT_TYPE instance) {
    this->ComponentBase::init(queueDepth, instance);
}

void MotorBridge::setMotorController(MotorController* controller) {
    m_controller = controller;
}

void MotorBridge::CmdSpeed_handler(NATIVE_INT_TYPE, float speed) {
    m_lastSpeed = speed;
    if(m_controller) m_controller->setSpeed(speed);
}

void MotorBridge::CmdEnable_handler(NATIVE_INT_TYPE, bool enable) {
    m_enabled = enable;
    if(m_controller) m_controller->setEnabled(enable);
}

void MotorBridge::sendPosition(float position) { this->FbPosition_out(0, position); }
void MotorBridge::sendVelocity(float velocity) { this->FbVelocity_out(0, velocity); }

} // namespace Motor
