#include "emuladorgba/session.h"

#include <stdlib.h>
#include <string.h>

struct emugba_session {
  uint8_t framebuffer[EMUGBA_FRAME_RGBA_SIZE];
  uint16_t buttons;
  char* rom_path;
  char* save_path;
};

static char* duplicate_text(const char* value) {
  size_t length;
  char* copy;
  if (value == NULL) return NULL;
  length = strlen(value);
  copy = (char*)malloc(length + 1u);
  if (copy == NULL) return NULL;
  memcpy(copy, value, length + 1u);
  return copy;
}

emugba_result emugba_session_create(
    const emugba_session_config* config,
    emugba_session** out_session) {
  emugba_session* session;
  if (config == NULL || out_session == NULL || config->rom_path == NULL ||
      config->rom_path[0] == '\0') {
    return EMUGBA_ERROR_INVALID_ARGUMENT;
  }
  *out_session = NULL;
  session = (emugba_session*)calloc(1u, sizeof(*session));
  if (session == NULL) return EMUGBA_ERROR_OUT_OF_MEMORY;
  session->rom_path = duplicate_text(config->rom_path);
  session->save_path = duplicate_text(config->save_path);
  if (session->rom_path == NULL ||
      (config->save_path != NULL && session->save_path == NULL)) {
    emugba_session_destroy(session);
    return EMUGBA_ERROR_OUT_OF_MEMORY;
  }
  *out_session = session;
  return EMUGBA_OK;
}

emugba_result emugba_session_run_frame(emugba_session* session) {
  if (session == NULL) return EMUGBA_ERROR_INVALID_ARGUMENT;
  return EMUGBA_ERROR_CORE_UNAVAILABLE;
}

emugba_result emugba_session_set_button(
    emugba_session* session,
    emugba_button button,
    int pressed) {
  uint16_t mask;
  if (session == NULL || button < EMUGBA_BUTTON_A || button > EMUGBA_BUTTON_L) {
    return EMUGBA_ERROR_INVALID_ARGUMENT;
  }
  mask = (uint16_t)(1u << (unsigned)button);
  if (pressed) {
    session->buttons = (uint16_t)(session->buttons | mask);
  } else {
    session->buttons = (uint16_t)(session->buttons & (uint16_t)~mask);
  }
  return EMUGBA_OK;
}

emugba_result emugba_session_copy_framebuffer(
    const emugba_session* session,
    uint8_t* output,
    size_t output_size) {
  if (session == NULL || output == NULL || output_size < EMUGBA_FRAME_RGBA_SIZE) {
    return EMUGBA_ERROR_INVALID_ARGUMENT;
  }
  memcpy(output, session->framebuffer, EMUGBA_FRAME_RGBA_SIZE);
  return EMUGBA_OK;
}

emugba_result emugba_session_flush_save(emugba_session* session) {
  if (session == NULL) return EMUGBA_ERROR_INVALID_ARGUMENT;
  return EMUGBA_ERROR_CORE_UNAVAILABLE;
}

void emugba_session_destroy(emugba_session* session) {
  if (session == NULL) return;
  free(session->rom_path);
  free(session->save_path);
  free(session);
}
