cmake_minimum_required(VERSION 3.20)
include("${FPRIME_PROJECT_ROOT}/cmake/FPrime.cmake")

# Register this as a top-level module
register_fprime_module(Stage8MotorBridge)

# Add subdirectory for the component
add_fprime_subdirectory("${CMAKE_CURRENT_LIST_DIR}/Components/MotorBridge")

# Optionally: Create a combined library if you want one .a file
register_fprime_library(Stage8MotorBridge)
