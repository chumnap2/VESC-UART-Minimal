#!/bin/bash

mkdir -p Topology

# --- TestCommandGenerator.hpp ---
cat > Topology/TestCommandGenerator.hpp << 'EOF'
#pragma once
#include "Fw/Comp/FwComponentBase.hpp"

class TestCommandGenerator : public Fw::ComponentBase {
public:
    TestCommandGenerator(const char* compName);
    void init(NATIVE_INT_TYPE queueDepth, NATIVE_INT_TYPE instance = 0);
    void generateCommands(float speed, bool enable);

    // Output ports to MotorBridge
    void CmdSpeed_out(NATIVE_INT_TYPE portNum, float speed);
    void CmdEnable_out(NATIVE_INT_TYPE portNum, bool enable);
};
EOF

# --- TestCommandGenerator.cpp ---
cat > Topology/TestCommandGenerator.cpp << 'EOF'
#include "TestCommandGenerator.hpp"

TestCommandGenerator::TestCommandGenerator(const char* compName)
    : Fw::ComponentBase(compName) {}

void TestCommandGenerator::init(NATIVE_INT_TYPE queueDepth, NATIVE_INT_TYPE instance) {
    this->ComponentBase::init(queueDepth, instance);
}

void TestCommandGenerator::generateCommands(float speed, bool enable) {
    CmdSpeed_out(0, speed);
    CmdEnable_out(0, enable);
}

void TestCommandGenerator::CmdSpeed_out(NATIVE_INT_TYPE portNum, float speed) {
    // placeholder, connected in topology
}

void TestCommandGenerator::CmdEnable_out(NATIVE_INT_TYPE portNum, bool enable) {
    // placeholder, connected in topology
}
EOF

# --- TelemetryLogger.hpp ---
cat > Topology/TelemetryLogger.hpp << 'EOF'
#pragma once
#include "Fw/Comp/FwComponentBase.hpp"

class TelemetryLogger : public Fw::ComponentBase {
public:
    TelemetryLogger(const char* compName);
    void init(NATIVE_INT_TYPE queueDepth, NATIVE_INT_TYPE instance = 0);

    void FbPosition_handler(NATIVE_INT_TYPE portNum, float position);
    void FbVelocity_handler(NATIVE_INT_TYPE portNum, float velocity);
};
EOF

# --- TelemetryLogger.cpp ---
cat > Topology/TelemetryLogger.cpp << 'EOF'
#include "TelemetryLogger.hpp"
#include <iostream>

TelemetryLogger::TelemetryLogger(const char* compName) : Fw::ComponentBase(compName) {}
void TelemetryLogger::init(NATIVE_INT_TYPE queueDepth, NATIVE_INT_TYPE instance) {
    this->ComponentBase::init(queueDepth, instance);
}

void TelemetryLogger::FbPosition_handler(NATIVE_INT_TYPE, float position) {
    std::cout << "[Telemetry] Position: " << position << std::endl;
}

void TelemetryLogger::FbVelocity_handler(NATIVE_INT_TYPE, float velocity) {
    std::cout << "[Telemetry] Velocity: " << velocity << std::endl;
}
EOF

# --- Topology.cpp ---
cat > Topology/Topology.cpp << 'EOF'
#include "MotorBridge.hpp"
#include "MotorController.hpp"
#include "TestCommandGenerator.hpp"
#include "TelemetryLogger.hpp"

int main() {
    // Instantiate components
    Motor::MotorController controller;
    Motor::MotorBridge bridge("MotorBridge");
    bridge.setMotorController(&controller);

    TestCommandGenerator generator("TestCmdGen");
    TelemetryLogger logger("TelemetryLogger");

    // Initialize components
    bridge.init(10);
    generator.init(10);
    logger.init(10);

    // Connect ports manually (simple simulation)
    // Here we just simulate sending commands and receiving feedback
    for (int t = 0; t <= 10; t++) {
        float speed = (t < 5) ? 1.0f : 2.0f;
        bool enable = true;

        // Send commands to MotorBridge
        bridge.CmdSpeed_handler(0, speed);
        bridge.CmdEnable_handler(0, enable);

        // Update MotorController (simulation)
        // Normally MotorBridge would call controller internally
        float position = controller.getPosition() + speed * 0.1f;
        float velocity = speed;

        // Send feedback
        bridge.sendPosition(position);
        bridge.sendVelocity(velocity);

        // Telemetry logger
        logger.FbPosition_handler(0, position);
        logger.FbVelocity_handler(0, velocity);
    }

    return 0;
}
EOF

echo "F′ test topology files created in Topology/ folder."
