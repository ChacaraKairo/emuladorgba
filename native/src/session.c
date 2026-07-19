#include "emuladorgba/session.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(EMUGBA_WITH_MGBA)
#include <mgba/core/core.h>
#include <mgba/core/interface.h>
#endif

#define EMUGBA_AUDIO_RING_FRAMES 32768u

struct emugba_session {
#if defined(EMUGBA_WITH_MGBA)
  struct mAVStream av_stream;
  struct mCore* core;
  color_t* native_framebuffer;
#endif
  uint8_t framebuffer[EMUGBA_FRAME_RGBA_SIZE];
  int16_t audio_ring[EMUGBA_AUDIO_RING_FRAMES * EMUGBA_AUDIO_CHANNELS];
  size_t audio_read_frame;
  size_t audio_write_frame;
  size_t audio_frame_count;
  unsigned audio_sample_rate;
  uint16_t buttons;
  int audio_enabled;
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

static emugba_result write_binary_atomic(
    const char* destination,
    const void* data,
    size_t size) {
  char* temporary;
  size_t path_length;
  FILE* file;
  int written;

  if (destination == NULL || data == NULL || size == 0u) {
    return EMUGBA_ERROR_INVALID_ARGUMENT;
  }

  path_length = strlen(destination);
  temporary = (char*)malloc(path_length + 5u);
  if (temporary == NULL) return EMUGBA_ERROR_OUT_OF_MEMORY;
  written = snprintf(temporary, path_length + 5u, "%s.tmp", destination);
  if (written < 0 || (size_t)written >= path_length + 5u) {
    free(temporary);
    return EMUGBA_ERROR_IO;
  }

  file = fopen(temporary, "wb");
  if (file == NULL) {
    free(temporary);
    return EMUGBA_ERROR_IO;
  }
  if (fwrite(data, 1u, size, file) != size || fflush(file) != 0 || fclose(file) != 0) {
    remove(temporary);
    free(temporary);
    return EMUGBA_ERROR_IO;
  }

  remove(destination);
  if (rename(temporary, destination) != 0) {
    remove(temporary);
    free(temporary);
    return EMUGBA_ERROR_IO;
  }
  free(temporary);
  return EMUGBA_OK;
}

#if defined(EMUGBA_WITH_MGBA)
static void audio_push(emugba_session* session, int16_t left, int16_t right) {
  size_t index;
  if (session == NULL || !session->audio_enabled) return;

  if (session->audio_frame_count == EMUGBA_AUDIO_RING_FRAMES) {
    session->audio_read_frame =
        (session->audio_read_frame + 1u) % EMUGBA_AUDIO_RING_FRAMES;
    --session->audio_frame_count;
  }

  index = session->audio_write_frame * EMUGBA_AUDIO_CHANNELS;
  session->audio_ring[index] = left;
  session->audio_ring[index + 1u] = right;
  session->audio_write_frame =
      (session->audio_write_frame + 1u) % EMUGBA_AUDIO_RING_FRAMES;
  ++session->audio_frame_count;
}

static void av_audio_rate_changed(struct mAVStream* stream, unsigned rate) {
  emugba_session* session = (emugba_session*)stream;
  if (rate > 0u) session->audio_sample_rate = rate;
}

static void av_post_audio_frame(
    struct mAVStream* stream,
    int16_t left,
    int16_t right) {
  audio_push((emugba_session*)stream, left, right);
}

static void copy_native_frame(emugba_session* session) {
  size_t index;
  for (index = 0u; index < EMUGBA_FRAME_WIDTH * EMUGBA_FRAME_HEIGHT; ++index) {
    const uint32_t pixel = (uint32_t)session->native_framebuffer[index];
    const size_t output = index * 4u;
    session->framebuffer[output] = (uint8_t)(pixel & 0xFFu);
    session->framebuffer[output + 1u] = (uint8_t)((pixel >> 8u) & 0xFFu);
    session->framebuffer[output + 2u] = (uint8_t)((pixel >> 16u) & 0xFFu);
    session->framebuffer[output + 3u] = 0xFFu;
  }
}

static void release_mgba(emugba_session* session) {
  if (session->core != NULL) {
    session->core->unloadROM(session->core);
    session->core->deinit(session->core);
    free(session->core);
    session->core = NULL;
  }
  free(session->native_framebuffer);
  session->native_framebuffer = NULL;
}

static emugba_result initialize_mgba(emugba_session* session) {
  FILE* save_file;

  session->core = mCoreFind(session->rom_path);
  if (session->core == NULL) return EMUGBA_ERROR_INVALID_ROM;
  if (!session->core->init(session->core)) {
    free(session->core);
    session->core = NULL;
    return EMUGBA_ERROR_CORE_UNAVAILABLE;
  }

  mCoreInitConfig(session->core, "emuladorgba");
  session->native_framebuffer = (color_t*)calloc(
      EMUGBA_FRAME_WIDTH * EMUGBA_FRAME_HEIGHT,
      sizeof(color_t));
  if (session->native_framebuffer == NULL) {
    release_mgba(session);
    return EMUGBA_ERROR_OUT_OF_MEMORY;
  }

  memset(&session->av_stream, 0, sizeof(session->av_stream));
  session->av_stream.audioRateChanged = av_audio_rate_changed;
  session->av_stream.postAudioFrame = av_post_audio_frame;
  session->core->setAVStream(session->core, &session->av_stream);
  session->core->setAudioBufferSize(session->core, 2048u);
  session->core->setVideoBuffer(
      session->core,
      session->native_framebuffer,
      EMUGBA_FRAME_WIDTH);

  if (!mCoreLoadFile(session->core, session->rom_path)) {
    release_mgba(session);
    return EMUGBA_ERROR_INVALID_ROM;
  }

  if (session->save_path != NULL && session->save_path[0] != '\0') {
    save_file = fopen(session->save_path, "ab");
    if (save_file == NULL) {
      release_mgba(session);
      return EMUGBA_ERROR_IO;
    }
    fclose(save_file);
    if (!mCoreLoadSaveFile(session->core, session->save_path, false)) {
      release_mgba(session);
      return EMUGBA_ERROR_IO;
    }
  }

  session->core->rtc.override = RTC_NO_OVERRIDE;
  session->core->reset(session->core);
  return EMUGBA_OK;
}
#endif

int emugba_session_backend_available(void) {
#if defined(EMUGBA_WITH_MGBA)
  return 1;
#else
  return 0;
#endif
}

emugba_result emugba_session_create(
    const emugba_session_config* config,
    emugba_session** out_session) {
  emugba_session* session;
  emugba_result result;

  if (config == NULL || out_session == NULL || config->rom_path == NULL ||
      config->rom_path[0] == '\0') {
    return EMUGBA_ERROR_INVALID_ARGUMENT;
  }

  *out_session = NULL;
  session = (emugba_session*)calloc(1u, sizeof(*session));
  if (session == NULL) return EMUGBA_ERROR_OUT_OF_MEMORY;

  session->rom_path = duplicate_text(config->rom_path);
  session->save_path = duplicate_text(config->save_path);
  session->audio_enabled = config->enable_audio != 0;
  session->audio_sample_rate = EMUGBA_AUDIO_SAMPLE_RATE;
  if (session->rom_path == NULL ||
      (config->save_path != NULL && session->save_path == NULL)) {
    emugba_session_destroy(session);
    return EMUGBA_ERROR_OUT_OF_MEMORY;
  }

#if defined(EMUGBA_WITH_MGBA)
  result = initialize_mgba(session);
#else
  result = EMUGBA_ERROR_CORE_UNAVAILABLE;
#endif
  if (result != EMUGBA_OK) {
    emugba_session_destroy(session);
    return result;
  }

  *out_session = session;
  return EMUGBA_OK;
}

emugba_result emugba_session_run_frame(emugba_session* session) {
  if (session == NULL) return EMUGBA_ERROR_INVALID_ARGUMENT;
#if defined(EMUGBA_WITH_MGBA)
  session->core->setKeys(session->core, session->buttons);
  session->core->runFrame(session->core);
  copy_native_frame(session);
  return EMUGBA_OK;
#else
  return EMUGBA_ERROR_CORE_UNAVAILABLE;
#endif
}

emugba_result emugba_session_reset(emugba_session* session) {
  if (session == NULL) return EMUGBA_ERROR_INVALID_ARGUMENT;
#if defined(EMUGBA_WITH_MGBA)
  session->core->reset(session->core);
  session->audio_read_frame = 0u;
  session->audio_write_frame = 0u;
  session->audio_frame_count = 0u;
  return EMUGBA_OK;
#else
  return EMUGBA_ERROR_CORE_UNAVAILABLE;
#endif
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

size_t emugba_session_read_audio(
    emugba_session* session,
    int16_t* output_interleaved,
    size_t maximum_frames) {
  size_t copied = 0u;
  if (session == NULL || output_interleaved == NULL) return 0u;

  while (copied < maximum_frames && session->audio_frame_count > 0u) {
    const size_t source = session->audio_read_frame * EMUGBA_AUDIO_CHANNELS;
    const size_t destination = copied * EMUGBA_AUDIO_CHANNELS;
    output_interleaved[destination] = session->audio_ring[source];
    output_interleaved[destination + 1u] = session->audio_ring[source + 1u];
    session->audio_read_frame =
        (session->audio_read_frame + 1u) % EMUGBA_AUDIO_RING_FRAMES;
    --session->audio_frame_count;
    ++copied;
  }
  return copied;
}

unsigned emugba_session_audio_sample_rate(const emugba_session* session) {
  return session == NULL ? 0u : session->audio_sample_rate;
}

emugba_result emugba_session_flush_save(emugba_session* session) {
  if (session == NULL) return EMUGBA_ERROR_INVALID_ARGUMENT;
  if (session->save_path == NULL || session->save_path[0] == '\0') {
    return EMUGBA_OK;
  }
#if defined(EMUGBA_WITH_MGBA)
  {
    void* save_data = NULL;
    const size_t save_size = session->core->savedataClone(session->core, &save_data);
    emugba_result result;
    if (save_size == 0u || save_data == NULL) return EMUGBA_ERROR_IO;
    result = write_binary_atomic(session->save_path, save_data, save_size);
    free(save_data);
    return result;
  }
#else
  return EMUGBA_ERROR_CORE_UNAVAILABLE;
#endif
}

void emugba_session_destroy(emugba_session* session) {
  if (session == NULL) return;
#if defined(EMUGBA_WITH_MGBA)
  if (session->core != NULL && session->save_path != NULL) {
    (void)emugba_session_flush_save(session);
  }
  release_mgba(session);
#endif
  free(session->rom_path);
  free(session->save_path);
  free(session);
}
