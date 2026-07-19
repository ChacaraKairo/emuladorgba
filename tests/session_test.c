#include "emuladorgba/session.h"

#include <assert.h>
#include <string.h>

int main(void) {
  emugba_session* session = NULL;
  emugba_session_config config;
  unsigned char framebuffer[EMUGBA_FRAME_RGBA_SIZE];

  memset(&config, 0, sizeof(config));
  config.rom_path = "test.gba";
  config.save_path = "test.sav";

  assert(emugba_session_create(NULL, &session) == EMUGBA_ERROR_INVALID_ARGUMENT);
  assert(emugba_session_create(&config, &session) == EMUGBA_OK);
  assert(session != NULL);
  assert(emugba_session_set_button(session, EMUGBA_BUTTON_A, 1) == EMUGBA_OK);
  assert(emugba_session_set_button(session, EMUGBA_BUTTON_A, 0) == EMUGBA_OK);
  assert(emugba_session_copy_framebuffer(
             session,
             framebuffer,
             sizeof(framebuffer)) == EMUGBA_OK);
  assert(emugba_session_run_frame(session) == EMUGBA_ERROR_CORE_UNAVAILABLE);
  assert(emugba_session_flush_save(session) == EMUGBA_ERROR_CORE_UNAVAILABLE);
  emugba_session_destroy(session);
  return 0;
}
