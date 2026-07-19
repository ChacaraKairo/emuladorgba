#ifndef EMULADORGBA_CORE_H
#define EMULADORGBA_CORE_H

#include <stddef.h>
#include <stdint.h>

#if defined(_WIN32)
  #if defined(EMULADORGBA_BUILD_SHARED)
    #define EMULADORGBA_API __declspec(dllexport)
  #else
    #define EMULADORGBA_API
  #endif
#else
  #define EMULADORGBA_API
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef enum emugba_result {
  EMUGBA_OK = 0,
  EMUGBA_ERROR_INVALID_ARGUMENT = 1,
  EMUGBA_ERROR_NOT_INITIALIZED = 2,
  EMUGBA_ERROR_ALREADY_INITIALIZED = 3,
  EMUGBA_ERROR_NOT_IMPLEMENTED = 4
} emugba_result;

typedef struct emugba_version {
  uint32_t major;
  uint32_t minor;
  uint32_t patch;
} emugba_version;

/** Returns the version of the wrapper API, not the embedded emulator core. */
EMULADORGBA_API emugba_version emugba_get_api_version(void);

/** Initializes process-level resources. Safe to call once per process. */
EMULADORGBA_API emugba_result emugba_initialize(void);

/** Releases process-level resources. */
EMULADORGBA_API void emugba_shutdown(void);

/** Returns a stable human-readable description for a result code. */
EMULADORGBA_API const char* emugba_result_message(emugba_result result);

#ifdef __cplusplus
}
#endif

#endif
