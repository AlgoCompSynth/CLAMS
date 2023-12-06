cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(CLAMS-stc C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

include_directories(${CMAKE_SOURCE_DIR})

add_executable(CLAMS-stc
  CLAMS-stc.S
  Dictionary.S
  ParamStack.S
  MacroDefs.S
  UserVars.S
  Wrappers.c
)

pico_enable_stdio_uart(CLAMS-stc 1)
pico_enable_stdio_usb(CLAMS-stc 1)

pico_add_extra_outputs(CLAMS-stc)

target_link_libraries(CLAMS-stc pico_stdlib)
