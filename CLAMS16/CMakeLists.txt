cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(CLAMS16 C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

include_directories(${CMAKE_SOURCE_DIR})

add_executable(CLAMS16
  CLAMS16.S
)

pico_enable_stdio_uart(CLAMS16 0)
pico_enable_stdio_usb(CLAMS16 1)

pico_add_extra_outputs(CLAMS16)

target_link_libraries(CLAMS16 pico_stdlib)
