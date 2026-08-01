#ifndef EMULADORGBA_SHA256_H
#define EMULADORGBA_SHA256_H

#include <stddef.h>
#include <stdint.h>

typedef struct emugba_sha256_context {
  uint8_t data[64];
  uint32_t state[8];
  uint64_t bit_length;
  size_t data_length;
} emugba_sha256_context;

void emugba_sha256_init(emugba_sha256_context* context);
void emugba_sha256_update(
    emugba_sha256_context* context,
    const uint8_t* data,
    size_t length);
void emugba_sha256_final(
    emugba_sha256_context* context,
    uint8_t digest[32]);
void emugba_sha256_to_hex(const uint8_t digest[32], char output[65]);

#endif
