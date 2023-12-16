cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(CLAMS-dtc C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

include_directories(${CMAKE_SOURCE_DIR})

add_executable(CLAMS-dtc
  CLAMS-dtc.S
  Dictionary.S
  DataSegment.S
  SymbolDefs.S
  Wrappers.c
)

pico_enable_stdio_uart(CLAMS-dtc 1)
pico_enable_stdio_usb(CLAMS-dtc 1)

pico_add_extra_outputs(CLAMS-dtc)

target_link_libraries(CLAMS-dtc pico_stdlib)
