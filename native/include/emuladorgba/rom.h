#ifndef EMULADORGBA_ROM_H
#define EMULADORGBA_ROM_H

#include "emuladorgba/core.h"

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define EMUGBA_ROM_TITLE_SIZE 13u
#define EMUGBA_ROM_GAME_CODE_SIZE 5u
#define EMUGBA_ROM_MAKER_CODE_SIZE 3u
#define EMUGBA_ROM_HASH_SIZE 65u

typedef struct emugba_rom_info {
  char title[EMUGBA_ROM_TITLE_SIZE];
  char game_code[EMUGBA_ROM_GAME_CODE_SIZE];
  char maker_code[EMUGBA_ROM_MAKER_CODE_SIZE];
  char sha256[EMUGBA_ROM_HASH_SIZE];
  uint64_t file_size;
  uint8_t software_version;
  uint8_t header_checksum;
  uint8_t computed_header_checksum;
  int header_checksum_valid;
} emugba_rom_info;

/**
 * Validates and inspects a Game Boy Advance ROM stored as a regular file.
 * The implementation never modifies the ROM file.
 */
EMULADORGBA_API emugba_result emugba_rom_inspect_file(
    const char* rom_path,
    emugba_rom_info* out_info);

/** Returns non-zero when the path has a supported ROM extension. */
EMULADORGBA_API int emugba_rom_has_supported_extension(const char* rom_path);

#ifdef __cplusplus
}
#endif

#endif
