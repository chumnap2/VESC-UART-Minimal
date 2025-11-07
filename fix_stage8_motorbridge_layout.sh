#!/bin/bash
set -e
echo "🧩 Fixing Stage8MotorBridge F´ layout and CMake order..."

rm -rf Components Topology Deployments
mkdir -p Components/MotorBridge
mkdir -p Topology
mkdir -p Deployments/MotorBridgeDeployment

# --- ROOT CMakeLists.txt ---
cat > CMakeLists.txt <<'EOF'
cmake_minimum_required(VERSION 3.13)
project(Stage8MotorBridge CXX)

# Path to the F´ framework
set(FPRIME_FRAMEWORK_PATH "/home/chumnap/fprime")

# Load F´ build system
include("${FPRIME_FRAMEWORK_PATH}/cmake/FPrime.cmake")

# Add the components and topology before deployments
add_fprime_subdirectory(Components)
add_fprime_subdirectory(Topology)
add_fprime_subdirectory(Deployments)
EOF

# --- Components/CMakeLists.txt ---
cat > Components/CMakeLists.txt <<'EOF'
# All F´ components
add_fprime_subdirectory(MotorBridge)
EOF

# --- Components/MotorBridge/CMakeLists.txt ---
cat > Components/MotorBridge/CMakeLists.txt <<'EOF'
register_fprime_module(
    SOURCES
        "${CMAKE_CURRENT_LIST_DIR}/MotorBridgeComponentAi.xml"
        "${CMAKE_CURRENT_LIST_DIR}/MotorBridge.cpp"
        "${CMAKE_CURRENT_LIST_DIR}/MotorBridge.hpp"
        "${CMAKE_CURRENT_LIST_DIR}/MotorController.cpp"
        "${CMAKE_CURRENT_LIST_DIR}/MotorController.hpp"
)
EOF

# --- MotorBridge sources ---
cat > Components/MotorBridge/MotorBridgeComponentAi.xml <<'EOF'
<component name="MotorBridge" kind="active">
    <ports>
        <port name="cmdIn" data_type="Fw::Cmd" kind="input"/>
        <port name="logOut" data_type="Fw::Log" kind="output"/>
    </ports>
</component>
EOF

cat > Components/MotorBridge/MotorBridge.hpp <<'EOF'
#ifndef STAGE8_MOTOR_BRIDGE_HPP
#define STAGE8_MOTOR_BRIDGE_HPP

#include "MotorBridgeComponentAc.hpp"

namespace Stage8 {

class MotorBridge : public MotorBridgeComponentBase {
  public:
    explicit MotorBridge(const char* compName);
    void init();
    void handleCmd(int arg);
};

} // namespace Stage8

#endif
EOF

cat > Components/MotorBridge/MotorBridge.cpp <<'EOF'
#include "MotorBridge.hpp"
#include <Fw/Log/Log.hpp>

namespace Stage8 {

MotorBridge::MotorBridge(const char* compName) : MotorBridgeComponentBase(compName) {}

void MotorBridge::init() {}

void MotorBridge::handleCmd(int arg) {
    FW_LOG_INFO("MotorBridge received command arg=%d", arg);
}

} // namespace Stage8
EOF

cat > Components/MotorBridge/MotorController.hpp <<'EOF'
#ifndef STAGE8_MOTOR_CONTROLLER_HPP
#define STAGE8_MOTOR_CONTROLLER_HPP

namespace Stage8 {

class MotorController {
  public:
    void setSpeed(float value);
};

} // namespace Stage8

#endif
EOF

cat > Components/MotorBridge/MotorController.cpp <<'EOF'
#include "MotorController.hpp"
#include <iostream>

namespace Stage8 {

void MotorController::setSpeed(float value) {
    std::cout << "[MotorController] Speed set to " << value << std::endl;
}

} // namespace Stage8
EOF

# --- Topology ---
cat > Topology/CMakeLists.txt <<'EOF'
register_fprime_module(
    SOURCES
        "${CMAKE_CURRENT_LIST_DIR}/MotorBridgeTopologyAppAi.xml"
        "${CMAKE_CURRENT_LIST_DIR}/MotorBridgeTopologyApp.cpp"
)
EOF

cat > Topology/MotorBridgeTopologyAppAi.xml <<'EOF'
<topology name="MotorBridgeTopology">
    <instance name="motorBridge" type="MotorBridge" base_id="0x100" />
</topology>
EOF

cat > Topology/MotorBridgeTopologyApp.cpp <<'EOF'
#include "Components/MotorBridge/MotorBridge.hpp"

namespace Stage8 {

void setupTopology() {
    static MotorBridge motorBridge("motorBridge");
    motorBridge.init();
}

} // namespace Stage8
EOF

# --- Deployments ---
mkdir -p Deployments/MotorBridgeDeployment
cat > Deployments/CMakeLists.txt <<'EOF'
# All deployment targets
add_fprime_subdirectory(MotorBridgeDeployment)
EOF

cat > Deployments/MotorBridgeDeployment/CMakeLists.txt <<'EOF'
add_fprime_deployment(MotorBridgeDeployment)
EOF

# --- settings.ini ---
cat > settings.ini <<'EOF'
[fprime]
framework_path = /home/chumnap/fprime
default_toolchain = native
EOF

echo "✅ Layout fixed!"
echo "Next steps:"
echo "  1. fprime-util purge"
echo "  2. fprime-util generate"
echo "  3. fprime-util build"
