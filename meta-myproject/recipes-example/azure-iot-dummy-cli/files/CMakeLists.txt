cmake_minimum_required(VERSION 3.0)
project(azure-iot-dummy-cli CXX)

set(CMAKE_CXX_STANDARD 11)

add_executable(azure-iot-dummy-cli main.cpp)

find_package(azure_iot_sdks REQUIRED)

target_link_libraries(azure-iot-dummy-cli
    iothub_client
    uamqp
)