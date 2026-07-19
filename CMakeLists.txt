cmake_minimum_required(VERSION 3.20)

project(emuladorgba VERSION 0.2.0 LANGUAGES C)

option(EMULADORGBA_BUILD_TESTS "Build native tests" ON)
option(EMULADORGBA_BUILD_CLI "Build ROM inspection CLI" ON)

add_library(emuladorgba_core STATIC
  native/src/core.c
  native/src/rom.c
  native/src/sha256.c
)

add_library(emuladorgba::core ALIAS emuladorgba_core)

target_include_directories(emuladorgba_core
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/native/include>
    $<INSTALL_INTERFACE:include>
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/native/src
)

target_compile_features(emuladorgba_core PUBLIC c_std_11)

function(emuladorgba_enable_warnings target)
  if(MSVC)
    target_compile_options(${target} PRIVATE /W4 /WX)
  else()
    target_compile_options(${target} PRIVATE -Wall -Wextra -Wpedantic -Werror)
  endif()
endfunction()

emuladorgba_enable_warnings(emuladorgba_core)

if(EMULADORGBA_BUILD_CLI)
  add_executable(emuladorgba_cli apps/cli/main.c)
  target_link_libraries(emuladorgba_cli PRIVATE emuladorgba::core)
  emuladorgba_enable_warnings(emuladorgba_cli)
endif()

if(EMULADORGBA_BUILD_TESTS)
  enable_testing()

  add_executable(emuladorgba_core_test tests/core_test.c)
  target_link_libraries(emuladorgba_core_test PRIVATE emuladorgba::core)
  emuladorgba_enable_warnings(emuladorgba_core_test)
  add_test(NAME emuladorgba_core_test COMMAND emuladorgba_core_test)

  add_executable(emuladorgba_rom_test tests/rom_test.c)
  target_link_libraries(emuladorgba_rom_test PRIVATE emuladorgba::core)
  emuladorgba_enable_warnings(emuladorgba_rom_test)
  add_test(NAME emuladorgba_rom_test COMMAND emuladorgba_rom_test)
endif()
