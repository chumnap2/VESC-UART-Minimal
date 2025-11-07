#!/bin/bash

mkdir -p MotorBridge

# --- MotorBridge XML for F′ codegen ---
cat > MotorBridge/MotorBridge.xml << 'EOF'
<component name="MotorBridge">
    <port name="CmdSpeed" type="input" dataType="F32"/>
    <port name="CmdEnable" type="input" dataType="bool"/>
    <port name="FbPosition" type="output" dataType="F32"/>
    <port name="FbVelocity" type="output" dataType="F32"/>
</component>
EOF

# --- MotorBridge.hpp ---
cat > MotorBridge/MotorBridge.hpp << 'EOF'
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
EOF

# --- MotorBridge.cpp ---
cat > MotorBridge/MotorBridge.cpp << 'EOF'
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
EOF

# --- MotorController.hpp ---
cat > MotorBridge/MotorController.hpp << 'EOF'
#pragma once

namespace Motor {

class MotorController {
public:
    MotorController();
    void setSpeed(float speed);
    void setEnabled(bool enable);

    float getPosition();
    float getVelocity();

private:
    float m_speed;
    bool m_enabled;
    float m_position;
    float m_velocity;
};

} // namespace Motor
EOF

# --- MotorController.cpp ---
cat > MotorBridge/MotorController.cpp << 'EOF'
#include "MotorController.hpp"

namespace Motor {

MotorController::MotorController() : m_speed(0), m_enabled(false),
    m_position(0), m_velocity(0) {}

void MotorController::setSpeed(float speed) { m_speed = speed; }
void MotorController::setEnabled(bool enable) { m_enabled = enable; }

float MotorController::getPosition() { return m_position; }
float MotorController::getVelocity() { return m_velocity; }

} // namespace Motor
EOF

echo "MotorBridge and MotorController files (including XML) created in MotorBridge/ folder."
