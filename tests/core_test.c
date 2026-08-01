#include "emuladorgba/core.h"

#include <assert.h>
#include <string.h>

int main(void) {
  const emugba_version version = emugba_get_api_version();
  assert(version.major == 0u);
  assert(version.minor == 1u);
  assert(version.patch == 0u);

  assert(emugba_initialize() == EMUGBA_OK);
  assert(emugba_initialize() == EMUGBA_ERROR_ALREADY_INITIALIZED);
  assert(strcmp(emugba_result_message(EMUGBA_OK), "success") == 0);

  emugba_shutdown();
  assert(emugba_initialize() == EMUGBA_OK);
  emugba_shutdown();

  return 0;
}
