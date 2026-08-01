#ifndef EMULADORGBA_SESSION_H
#define EMULADORGBA_SESSION_H

#include <stddef.h>
#include <stdint.h>

#include "emuladorgba/core.h"

#ifdef __cplusplus
extern "C" {
#endif

#define EMUGBA_FRAME_WIDTH 240u
#define EMUGBA_FRAME_HEIGHT 160u
#define EMUGBA_FRAME_RGBA_SIZE (EMUGBA_FRAME_WIDTH * EMUGBA_FRAME_HEIGHT * 4u)
#define EMUGBA_AUDIO_SAMPLE_RATE 32768u
#define EMUGBA_AUDIO_CHANNELS 2u

typedef struct emugba_session emugba_session;

typedef enum emugba_button {
  EMUGBA_BUTTON_A = 0,
  EMUGBA_BUTTON_B = 1,
  EMUGBA_BUTTON_SELECT = 2,
  EMUGBA_BUTTON_START = 3,
  EMUGBA_BUTTON_RIGHT = 4,
  EMUGBA_BUTTON_LEFT = 5,
  EMUGBA_BUTTON_UP = 6,
  EMUGBA_BUTTON_DOWN = 7,
  EMUGBA_BUTTON_R = 8,
  EMUGBA_BUTTON_L = 9
} emugba_button;

typedef struct emugba_session_config {
  const char* rom_path;
  const char* save_path;
  int enable_audio;
} emugba_session_config;

EMULADORGBA_API int emugba_session_backend_available(void);
EMULADORGBA_API emugba_result emugba_session_create(
    const emugba_session_config* config,
    emugba_session** out_session);
EMULADORGBA_API emugba_result emugba_session_run_frame(
    emugba_session* session);
EMULADORGBA_API emugba_result emugba_session_reset(
    emugba_session* session);
EMULADORGBA_API emugba_result emugba_session_set_button(
    emugba_session* session,
    emugba_button button,
    int pressed);
EMULADORGBA_API emugba_result emugba_session_copy_framebuffer(
    const emugba_session* session,
    uint8_t* output,
    size_t output_size);
EMULADORGBA_API size_t emugba_session_read_audio(
    emugba_session* session,
    int16_t* output_interleaved,
    size_t maximum_frames);
EMULADORGBA_API unsigned emugba_session_audio_sample_rate(
    const emugba_session* session);
EMULADORGBA_API emugba_result emugba_session_flush_save(
    emugba_session* session);
EMULADORGBA_API void emugba_session_destroy(emugba_session* session);

#ifdef __cplusplus
}
#endif

#endif
