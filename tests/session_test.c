#include "emuladorgba/session.h"

#include <assert.h>
#include <string.h>

int main(void) {
  emugba_session* session = NULL;
  emugba_session_config config;
  emugba_result result;

  memset(&config, 0, sizeof(config));
  config.rom_path = "arquivo-inexistente.gba";
  config.save_path = "arquivo-inexistente.sav";
  config.enable_audio = 1;

  assert(emugba_session_create(NULL, &session) == EMUGBA_ERROR_INVALID_ARGUMENT);
  assert(emugba_session_backend_available() == 0 ||
         emugba_session_backend_available() == 1);

  result = emugba_session_create(&config, &session);
  if (emugba_session_backend_available()) {
    assert(result == EMUGBA_ERROR_INVALID_ROM || result == EMUGBA_ERROR_IO);
  } else {
    assert(result == EMUGBA_ERROR_CORE_UNAVAILABLE);
  }
  assert(session == NULL);
  assert(emugba_session_audio_sample_rate(NULL) == 0u);
  assert(emugba_session_read_audio(NULL, NULL, 0u) == 0u);
  return 0;
}
