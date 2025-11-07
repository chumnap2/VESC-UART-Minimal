#!/bin/bash
set -e

echo "🧱 Rebuilding Stage8MotorBridge layout and F´ files..."

# -----------------------------
# 1️⃣ Ensure folder structure
# -----------------------------
mkdir -p Components/MotorBridge
mkdir -p Topology
mkdir -p Deployments/MotorBridgeDeployment

# -----------------------------
# 2️⃣ Create minimal valid F´ XMLs
# -----------------------------
cat > Components/MotorBridge/MotorBridgeComponentAi.xml <<'EOF'
<?xml version="1.0"?>
<components>
    <component name="MotorBridge" type="active">
        <ports>
            <port name="cmd" type="input"/>
            <port name="status" type="output"/>
        </ports>
    </component>
</components>
EOF

cat > Topology/TopologyComponentAi.xml <<'EOF'
<?xml version="1.0"?>
<components>
    <component name="Topology" type="active">
        <ports>
            <port name="topology_in" type="input"/>
            <port name="topology_out" type="output"/>
        </ports>
    </component>
</components>
EOF

# -----------------------------
# 3️⃣ Patch CMakeLists.txt
# -----------------------------

# Root CMakeLists.txt
cat > CMakeLists.txt <<'EOF'
cmake_minimum_required(VERSION 3.13)
project(Stage8MotorBridge CXX)

set(FPRIME_FRAMEWORK_PATH "/home/chumnap/fprime")
include("${FPRIME_FRAMEWORK_PATH}/cmake/FPrime.cmake")

# Add project directories
add_fprime_subdirectory(Components)
add_fprime_subdirectory(Topology)
add_fprime_subdirectory(Deployments)
EOF

# Components CMakeLists.txt
mkdir -p Components
cat > Components/CMakeLists.txt <<'EOF'
add_fprime_subdirectory(MotorBridge)
EOF

# MotorBridge CMakeLists.txt
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

# Topology CMakeLists.txt
cat > Topology/CMakeLists.txt <<'EOF'
register_fprime_module(
    SOURCES
        "${CMAKE_CURRENT_LIST_DIR}/TopologyComponentAi.xml"
)
EOF

# Deployments CMakeLists.txt
mkdir -p Deployments
cat > Deployments/CMakeLists.txt <<'EOF'
add_fprime_subdirectory(MotorBridgeDeployment)
EOF

# MotorBridgeDeployment CMakeLists.txt
mkdir -p Deployments/MotorBridgeDeployment
cat > Deployments/MotorBridgeDeployment/CMakeLists.txt <<'EOF'
add_fprime_deployment(MotorBridgeDeployment)
EOF

# -----------------------------
# 4️⃣ Create placeholder CPP/HPP files
# -----------------------------
touch Components/MotorBridge/{MotorBridge.cpp,MotorBridge.hpp,MotorController.cpp,MotorController.hpp}

# -----------------------------
# 5️⃣ Purge old builds and caches
# -----------------------------
fprime-util purge

# -----------------------------
# 6️⃣ Generate and build
# -----------------------------
fprime-util generate
fprime-util build

echo "✅ Stage8MotorBridge is fully rebuilt and ready!"
