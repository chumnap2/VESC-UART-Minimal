#!/bin/bash
set -e

echo "🧱 Rebuilding Stage8MotorBridge layout..."

# Clean up old folders if they exist
rm -rf Components Topology Deployments
mkdir -p Components/MotorBridge
mkdir -p Topology
mkdir -p Deployments/MotorBridgeDeployment

# -------------------------
# 1️⃣ Top-level CMakeLists.txt
# -------------------------
cat > CMakeLists.txt <<'EOF'
cmake_minimum_required(VERSION 3.13)
project(Stage8MotorBridge CXX)

# Path to F´ framework
set(FPRIME_FRAMEWORK_PATH "/home/chumnap/fprime")

# Include F´ build system
include("${FPRIME_FRAMEWORK_PATH}/cmake/FPrime.cmake")

# Add subdirectories
add_fprime_subdirectory(Components)
add_fprime_subdirectory(Topology)
add_fprime_subdirectory(Deployments/MotorBridgeDeployment)
EOF

# -------------------------
# 2️⃣ settings.ini
# -------------------------
cat > settings.ini <<'EOF'
[fprime]
framework_path = /home/chumnap/fprime
default_toolchain = native
EOF

# -------------------------
# 3️⃣ Component: MotorBridge
# -------------------------
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

cat > Components/MotorBridge/MotorBridgeComponentAi.xml <<'EOF'
<component name="MotorBridge" kind="active">
    <ports>
        <port name="cmdIn" data_type="Fw::Cmd" kind="input"/>
        <port name="logOut" data_type="Fw::Log" kind="output"/>
    </ports>
</component>
EOF

cat > Components/MotorBridge/MotorBridge.cpp <<'EOF'
#include "MotorBridge.hpp"
#include <Fw/Log/Log.hpp>

namespace Stage8 {

MotorBridge::MotorBridge(const char* compName) : MotorBridgeComponentBase(compName) {}

void MotorBridge::init() {
    // Initialize component state here
}

void MotorBridge::handleCmd(int arg) {
    FW_LOG_INFO("MotorBridge received command arg=%d", arg);
}

} // namespace Stage8
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

cat > Components/MotorBridge/MotorController.cpp <<'EOF'
#include "MotorController.hpp"
#include <iostream>

namespace Stage8 {

void MotorController::setSpeed(float value) {
    std::cout << "[MotorController] Speed set to " << value << std::endl;
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

# -------------------------
# 4️⃣ Topology
# -------------------------
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
#include <Fw/Types/Assert.hpp>

namespace Stage8 {

void setupTopology() {
    static MotorBridge motorBridge("motorBridge");
    motorBridge.init();
}

} // namespace Stage8
EOF

# -------------------------
# 5️⃣ Deployment
# -------------------------
cat > Deployments/MotorBridgeDeployment/CMakeLists.txt <<'EOF'
add_fprime_deployment(MotorBridgeDeployment)
EOF

# -------------------------
# 6️⃣ Done
# -------------------------
echo "✅ F´ Stage8MotorBridge structure rebuilt successfully!"
echo
echo "Next steps:"
echo "  1. fprime-util purge"
echo "  2. fprime-util generate"
echo "  3. fprime-util build"
