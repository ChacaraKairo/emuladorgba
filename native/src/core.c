#include "emuladorgba/core.h"

#include <stdbool.h>

static bool g_initialized = false;

emugba_version emugba_get_api_version(void) {
  const emugba_version version = {0u, 2u, 0u};
  return version;
}

emugba_result emugba_initialize(void) {
  if (g_initialized) {
    return EMUGBA_ERROR_ALREADY_INITIALIZED;
  }

  g_initialized = true;
  return EMUGBA_OK;
}

void emugba_shutdown(void) {
  g_initialized = false;
}

int emugba_is_initialized(void) {
  return g_initialized ? 1 : 0;
}

const char* emugba_result_message(emugba_result result) {
  switch (result) {
    case EMUGBA_OK:
      return "success";
    case EMUGBA_ERROR_INVALID_ARGUMENT:
      return "invalid argument";
    case EMUGBA_ERROR_NOT_INITIALIZED:
      return "core is not initialized";
    case EMUGBA_ERROR_ALREADY_INITIALIZED:
      return "core is already initialized";
    case EMUGBA_ERROR_NOT_IMPLEMENTED:
      return "operation is not implemented";
    case EMUGBA_ERROR_IO:
      return "input/output error";
    case EMUGBA_ERROR_FILE_NOT_FOUND:
      return "file not found";
    case EMUGBA_ERROR_UNSUPPORTED_FILE:
      return "unsupported file type";
    case EMUGBA_ERROR_INVALID_ROM:
      return "invalid or truncated GBA ROM";
    case EMUGBA_ERROR_OUT_OF_MEMORY:
      return "out of memory";
    case EMUGBA_ERROR_CORE_UNAVAILABLE:
      return "emulator backend is unavailable";
    default:
      return "unknown result";
  }
}
