#include "emuladorgba/core.h"

#include <stdbool.h>

static bool g_initialized = false;

emugba_version emugba_get_api_version(void) {
  const emugba_version version = {0u, 1u, 0u};
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
    default:
      return "unknown result";
  }
}
