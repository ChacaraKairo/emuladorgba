cmake_minimum_required(VERSION 3.20)

project(emuladorgba VERSION 0.5.0 LANGUAGES C)

include(FetchContent)

option(EMULADORGBA_BUILD_TESTS "Build native tests" ON)
option(EMULADORGBA_BUILD_CLI "Build ROM inspection CLI" ON)
option(EMULADORGBA_ENABLE_WERROR "Treat project warnings as errors" OFF)
option(EMULADORGBA_WITH_MGBA "Build the embedded mGBA backend" ON)

if(EMULADORGBA_WITH_MGBA)
  set(LIBMGBA_ONLY ON CACHE BOOL "" FORCE)
  set(M_CORE_GBA ON CACHE BOOL "" FORCE)
  set(M_CORE_GB OFF CACHE BOOL "" FORCE)
  set(BUILD_STATIC ON CACHE BOOL "" FORCE)
  set(BUILD_SHARED OFF CACHE BOOL "" FORCE)
  set(BUILD_LTO OFF CACHE BOOL "" FORCE)
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)

  FetchContent_Declare(
    mgba
    GIT_REPOSITORY https://github.com/mgba-emu/mgba.git
    GIT_TAG 0.10.5
    GIT_SHALLOW TRUE
  )
  FetchContent_MakeAvailable(mgba)
endif()

add_library(emuladorgba_core SHARED
  native/src/core.c
  native/src/rom.c
  native/src/sha256.c
  native/src/storage.c
  native/src/session.c
)

add_library(emuladorgba::core ALIAS emuladorgba_core)

set_target_properties(emuladorgba_core PROPERTIES
  OUTPUT_NAME emuladorgba_core
  POSITION_INDEPENDENT_CODE ON
)

target_include_directories(emuladorgba_core
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/native/include>
    $<INSTALL_INTERFACE:include>
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/native/src
)

target_compile_features(emuladorgba_core PUBLIC c_std_11)
target_compile_definitions(emuladorgba_core PRIVATE EMULADORGBA_BUILD_SHARED)

if(EMULADORGBA_WITH_MGBA)
  target_compile_definitions(emuladorgba_core PRIVATE EMUGBA_WITH_MGBA=1)
  target_link_libraries(emuladorgba_core PRIVATE mgba)
endif()

function(emuladorgba_enable_warnings target)
  if(MSVC)
    target_compile_options(${target} PRIVATE /W4)
    target_compile_definitions(${target} PRIVATE _CRT_SECURE_NO_WARNINGS)
    if(EMULADORGBA_ENABLE_WERROR)
      target_compile_options(${target} PRIVATE /WX)
    endif()
  else()
    target_compile_options(${target} PRIVATE -Wall -Wextra -Wpedantic)
    if(EMULADORGBA_ENABLE_WERROR)
      target_compile_options(${target} PRIVATE -Werror)
    endif()
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

  add_executable(emuladorgba_storage_test tests/storage_test.c)
  target_link_libraries(emuladorgba_storage_test PRIVATE emuladorgba::core)
  emuladorgba_enable_warnings(emuladorgba_storage_test)
  add_test(NAME emuladorgba_storage_test COMMAND emuladorgba_storage_test)

  add_executable(emuladorgba_session_test tests/session_test.c)
  target_link_libraries(emuladorgba_session_test PRIVATE emuladorgba::core)
  emuladorgba_enable_warnings(emuladorgba_session_test)
  add_test(NAME emuladorgba_session_test COMMAND emuladorgba_session_test)
endif()
