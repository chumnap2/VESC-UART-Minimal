#include "Components/MotorBridgeComponentAc.hpp"
#include <iostream>

int main() {
    // Instantiate the MotorBridge component
    Components::MotorBridgeComponent motorBridge("MotorBridge");

    // Simulate sending a command
    FwOpcodeType testOp = 1;
    U32 testSeq = 42;

    std::cout << "Sending test command to MotorBridge...\n";
    motorBridge.cmdIn.invoke(testOp, testSeq);

    return 0;
}
