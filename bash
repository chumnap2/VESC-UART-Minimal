#!/bin/bash
set -e

echo "🧱 Fixing Stage8MotorBridge folder layout and missing files..."

# Ensure Components folder CMakeLists exists (already mostly done)
cat > Components/CMakeLists.txt << 'EOF'
add_fprime_subdirectory(MotorBridge)
EOF

# Ensure Topology folder exists and has minimal CMakeLists
mkdir -p Topology
cat > Topology/CMakeLists.txt << 'EOF'
register_fprime_module(
    SOURCES
        "${CMAKE_CURRENT_LIST_DIR}/TopologyComponentAi.xml"
)
EOF

# Add a placeholder XML so FPP has something to parse
cat > Topology/TopologyComponentAi.xml << 'EOF'
<?xml version="1.0"?>
<component name="Topology">
</component>
EOF

# Ensure Deployments folder and its subfolder exist
mkdir -p Deployments/MotorBridgeDeployment
cat > Deployments/CMakeLists.txt << 'EOF'
add_fprime_subdirectory(MotorBridgeDeployment)
EOF

cat > Deployments/MotorBridgeDeployment/CMakeLists.txt << 'EOF'
add_fprime_deployment(MotorBridgeDeployment)
EOF

echo "✅ Folder structure and minimal files created."

echo "Next steps:"
echo "  1. fprime-util purge"
echo "  2. fprime-util generate"
echo "  3. fprime-util build"
