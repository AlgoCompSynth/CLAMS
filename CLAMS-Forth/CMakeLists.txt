cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(CLAMS-Forth C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

include_directories(${CMAKE_SOURCE_DIR})

add_executable(CLAMS-Forth
  CLAMS-Forth.S
  DataSegment.S
  Dictionary.S
  DictMacros.S
  MacroDefs.S
  SymbolDefs.S
  VirtMachMacros.S
  Wrappers.c
)

pico_enable_stdio_uart(CLAMS-Forth 1)
pico_enable_stdio_usb(CLAMS-Forth 1)

pico_add_extra_outputs(CLAMS-Forth)

target_link_libraries(CLAMS-Forth pico_stdlib)
