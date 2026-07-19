cmake_minimum_required(VERSION 3.20)

project(emuladorgba VERSION 0.1.0 LANGUAGES C)

option(EMULADORGBA_BUILD_TESTS "Build native tests" ON)

add_library(emuladorgba_core STATIC
  native/src/core.c
)

add_library(emuladorgba::core ALIAS emuladorgba_core)

target_include_directories(emuladorgba_core
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/native/include>
    $<INSTALL_INTERFACE:include>
)

target_compile_features(emuladorgba_core PUBLIC c_std_11)

if(MSVC)
  target_compile_options(emuladorgba_core PRIVATE /W4 /WX)
else()
  target_compile_options(emuladorgba_core PRIVATE -Wall -Wextra -Wpedantic -Werror)
endif()

if(EMULADORGBA_BUILD_TESTS)
  enable_testing()
  add_executable(emuladorgba_core_test tests/core_test.c)
  target_link_libraries(emuladorgba_core_test PRIVATE emuladorgba::core)
  add_test(NAME emuladorgba_core_test COMMAND emuladorgba_core_test)
endif()
