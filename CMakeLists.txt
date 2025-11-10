cmake_minimum_required(VERSION 3.10)
project(minimal_vesc_ramp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include_directories(${PROJECT_SOURCE_DIR}/include)

set(SOURCES
    src/main.cpp
)

add_executable(minimal_vesc_ramp ${SOURCES})

find_package(Threads REQUIRED)
target_link_libraries(minimal_vesc_ramp PRIVATE Threads::Threads)
