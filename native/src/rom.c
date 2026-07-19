#include "emuladorgba/rom.h"

#include "sha256.h"

#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>

#define GBA_HEADER_MINIMUM_SIZE 0xC0u
#define GBA_TITLE_OFFSET 0xA0u
#define GBA_GAME_CODE_OFFSET 0xACu
#define GBA_MAKER_CODE_OFFSET 0xB0u
#define GBA_SOFTWARE_VERSION_OFFSET 0xBCu
#define GBA_HEADER_CHECKSUM_OFFSET 0xBDu
#define GBA_CHECKSUM_START 0xA0u
#define GBA_CHECKSUM_END 0xBCu
#define READ_BUFFER_SIZE 65536u

static int equals_ignore_case(const char* left, const char* right) {
  while (*left != '\0' && *right != '\0') {
    if (tolower((unsigned char)*left) != tolower((unsigned char)*right)) {
      return 0;
    }
    ++left;
    ++right;
  }
  return *left == '\0' && *right == '\0';
}

static void copy_header_text(
    char* output,
    size_t output_size,
    const uint8_t* input,
    size_t input_size) {
  size_t index;
  size_t end = input_size;

  while (end > 0u && (input[end - 1u] == 0u || input[end - 1u] == ' ')) {
    --end;
  }

  if (end >= output_size) {
    end = output_size - 1u;
  }

  for (index = 0u; index < end; ++index) {
    const unsigned char value = input[index];
    output[index] = isprint(value) ? (char)value : '?';
  }
  output[end] = '\0';
}

static uint8_t calculate_header_checksum(const uint8_t* header) {
  uint8_t checksum = 0u;
  size_t index;
  for (index = GBA_CHECKSUM_START; index < GBA_CHECKSUM_END; ++index) {
    checksum = (uint8_t)(checksum - header[index]);
  }
  return (uint8_t)(checksum - 0x19u);
}

int emugba_rom_has_supported_extension(const char* rom_path) {
  const char* extension;
  if (rom_path == NULL) {
    return 0;
  }

  extension = strrchr(rom_path, '.');
  return extension != NULL && equals_ignore_case(extension, ".gba");
}

emugba_result emugba_rom_inspect_file(
    const char* rom_path,
    emugba_rom_info* out_info) {
  FILE* file;
  uint8_t header[GBA_HEADER_MINIMUM_SIZE];
  uint8_t buffer[READ_BUFFER_SIZE];
  uint8_t digest[32];
  emugba_sha256_context hash_context;
  size_t bytes_read;
  uint64_t total_size = 0u;

  if (rom_path == NULL || out_info == NULL || rom_path[0] == '\0') {
    return EMUGBA_ERROR_INVALID_ARGUMENT;
  }
  if (!emugba_rom_has_supported_extension(rom_path)) {
    return EMUGBA_ERROR_UNSUPPORTED_FILE;
  }

  file = fopen(rom_path, "rb");
  if (file == NULL) {
    return errno == ENOENT ? EMUGBA_ERROR_FILE_NOT_FOUND : EMUGBA_ERROR_IO;
  }

  bytes_read = fread(header, 1u, sizeof(header), file);
  if (bytes_read != sizeof(header)) {
    fclose(file);
    return ferror(file) ? EMUGBA_ERROR_IO : EMUGBA_ERROR_INVALID_ROM;
  }

  emugba_sha256_init(&hash_context);
  emugba_sha256_update(&hash_context, header, sizeof(header));
  total_size = sizeof(header);

  while ((bytes_read = fread(buffer, 1u, sizeof(buffer), file)) > 0u) {
    emugba_sha256_update(&hash_context, buffer, bytes_read);
    total_size += (uint64_t)bytes_read;
  }

  if (ferror(file)) {
    fclose(file);
    return EMUGBA_ERROR_IO;
  }
  fclose(file);

  memset(out_info, 0, sizeof(*out_info));
  copy_header_text(
      out_info->title,
      sizeof(out_info->title),
      &header[GBA_TITLE_OFFSET],
      12u);
  copy_header_text(
      out_info->game_code,
      sizeof(out_info->game_code),
      &header[GBA_GAME_CODE_OFFSET],
      4u);
  copy_header_text(
      out_info->maker_code,
      sizeof(out_info->maker_code),
      &header[GBA_MAKER_CODE_OFFSET],
      2u);

  out_info->file_size = total_size;
  out_info->software_version = header[GBA_SOFTWARE_VERSION_OFFSET];
  out_info->header_checksum = header[GBA_HEADER_CHECKSUM_OFFSET];
  out_info->computed_header_checksum = calculate_header_checksum(header);
  out_info->header_checksum_valid =
      out_info->header_checksum == out_info->computed_header_checksum;

  emugba_sha256_final(&hash_context, digest);
  emugba_sha256_to_hex(digest, out_info->sha256);

  return EMUGBA_OK;
}
