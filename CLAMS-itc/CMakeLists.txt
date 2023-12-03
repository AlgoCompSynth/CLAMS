cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(CLAMS-itc C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

include_directories(${CMAKE_SOURCE_DIR})

add_executable(CLAMS-itc
  CLAMS-itc.S
  Dictionary.S
  Stacks.S
  SymbolDefs.S
  Wrappers.c
)

pico_enable_stdio_uart(CLAMS-itc 1)
pico_enable_stdio_usb(CLAMS-itc 1)

pico_add_extra_outputs(CLAMS-itc)

target_link_libraries(CLAMS-itc pico_stdlib)
