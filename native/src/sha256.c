#include "sha256.h"

#include <string.h>

#define ROTR(value, bits) (((value) >> (bits)) | ((value) << (32u - (bits))))
#define CH(x, y, z) (((x) & (y)) ^ (~(x) & (z)))
#define MAJ(x, y, z) (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))
#define EP0(x) (ROTR((x), 2u) ^ ROTR((x), 13u) ^ ROTR((x), 22u))
#define EP1(x) (ROTR((x), 6u) ^ ROTR((x), 11u) ^ ROTR((x), 25u))
#define SIG0(x) (ROTR((x), 7u) ^ ROTR((x), 18u) ^ ((x) >> 3u))
#define SIG1(x) (ROTR((x), 17u) ^ ROTR((x), 19u) ^ ((x) >> 10u))

static const uint32_t k_constants[64] = {
  0x428a2f98u, 0x71374491u, 0xb5c0fbcfu, 0xe9b5dba5u,
  0x3956c25bu, 0x59f111f1u, 0x923f82a4u, 0xab1c5ed5u,
  0xd807aa98u, 0x12835b01u, 0x243185beu, 0x550c7dc3u,
  0x72be5d74u, 0x80deb1feu, 0x9bdc06a7u, 0xc19bf174u,
  0xe49b69c1u, 0xefbe4786u, 0x0fc19dc6u, 0x240ca1ccu,
  0x2de92c6fu, 0x4a7484aau, 0x5cb0a9dcu, 0x76f988dau,
  0x983e5152u, 0xa831c66du, 0xb00327c8u, 0xbf597fc7u,
  0xc6e00bf3u, 0xd5a79147u, 0x06ca6351u, 0x14292967u,
  0x27b70a85u, 0x2e1b2138u, 0x4d2c6dfcu, 0x53380d13u,
  0x650a7354u, 0x766a0abbu, 0x81c2c92eu, 0x92722c85u,
  0xa2bfe8a1u, 0xa81a664bu, 0xc24b8b70u, 0xc76c51a3u,
  0xd192e819u, 0xd6990624u, 0xf40e3585u, 0x106aa070u,
  0x19a4c116u, 0x1e376c08u, 0x2748774cu, 0x34b0bcb5u,
  0x391c0cb3u, 0x4ed8aa4au, 0x5b9cca4fu, 0x682e6ff3u,
  0x748f82eeu, 0x78a5636fu, 0x84c87814u, 0x8cc70208u,
  0x90befffau, 0xa4506cebu, 0xbef9a3f7u, 0xc67178f2u
};

static void transform(emugba_sha256_context* context, const uint8_t data[64]) {
  uint32_t schedule[64];
  uint32_t a;
  uint32_t b;
  uint32_t c;
  uint32_t d;
  uint32_t e;
  uint32_t f;
  uint32_t g;
  uint32_t h;
  size_t index;

  for (index = 0u; index < 16u; ++index) {
    const size_t offset = index * 4u;
    schedule[index] = ((uint32_t)data[offset] << 24u)
        | ((uint32_t)data[offset + 1u] << 16u)
        | ((uint32_t)data[offset + 2u] << 8u)
        | ((uint32_t)data[offset + 3u]);
  }

  for (index = 16u; index < 64u; ++index) {
    schedule[index] = SIG1(schedule[index - 2u])
        + schedule[index - 7u]
        + SIG0(schedule[index - 15u])
        + schedule[index - 16u];
  }

  a = context->state[0];
  b = context->state[1];
  c = context->state[2];
  d = context->state[3];
  e = context->state[4];
  f = context->state[5];
  g = context->state[6];
  h = context->state[7];

  for (index = 0u; index < 64u; ++index) {
    const uint32_t first = h + EP1(e) + CH(e, f, g)
        + k_constants[index] + schedule[index];
    const uint32_t second = EP0(a) + MAJ(a, b, c);
    h = g;
    g = f;
    f = e;
    e = d + first;
    d = c;
    c = b;
    b = a;
    a = first + second;
  }

  context->state[0] += a;
  context->state[1] += b;
  context->state[2] += c;
  context->state[3] += d;
  context->state[4] += e;
  context->state[5] += f;
  context->state[6] += g;
  context->state[7] += h;
}

void emugba_sha256_init(emugba_sha256_context* context) {
  memset(context, 0, sizeof(*context));
  context->state[0] = 0x6a09e667u;
  context->state[1] = 0xbb67ae85u;
  context->state[2] = 0x3c6ef372u;
  context->state[3] = 0xa54ff53au;
  context->state[4] = 0x510e527fu;
  context->state[5] = 0x9b05688cu;
  context->state[6] = 0x1f83d9abu;
  context->state[7] = 0x5be0cd19u;
}

void emugba_sha256_update(
    emugba_sha256_context* context,
    const uint8_t* data,
    size_t length) {
  size_t index;
  for (index = 0u; index < length; ++index) {
    context->data[context->data_length++] = data[index];
    if (context->data_length == 64u) {
      transform(context, context->data);
      context->bit_length += 512u;
      context->data_length = 0u;
    }
  }
}

void emugba_sha256_final(
    emugba_sha256_context* context,
    uint8_t digest[32]) {
  size_t index = context->data_length;
  size_t state_index;

  context->data[index++] = 0x80u;
  if (index > 56u) {
    while (index < 64u) {
      context->data[index++] = 0u;
    }
    transform(context, context->data);
    index = 0u;
  }

  while (index < 56u) {
    context->data[index++] = 0u;
  }

  context->bit_length += (uint64_t)context->data_length * 8u;
  for (index = 0u; index < 8u; ++index) {
    context->data[63u - index] =
        (uint8_t)(context->bit_length >> (index * 8u));
  }
  transform(context, context->data);

  for (state_index = 0u; state_index < 8u; ++state_index) {
    digest[state_index * 4u] = (uint8_t)(context->state[state_index] >> 24u);
    digest[state_index * 4u + 1u] =
        (uint8_t)(context->state[state_index] >> 16u);
    digest[state_index * 4u + 2u] =
        (uint8_t)(context->state[state_index] >> 8u);
    digest[state_index * 4u + 3u] =
        (uint8_t)context->state[state_index];
  }
}

void emugba_sha256_to_hex(const uint8_t digest[32], char output[65]) {
  static const char digits[] = "0123456789abcdef";
  size_t index;
  for (index = 0u; index < 32u; ++index) {
    output[index * 2u] = digits[digest[index] >> 4u];
    output[index * 2u + 1u] = digits[digest[index] & 0x0fu];
  }
  output[64] = '\0';
}
