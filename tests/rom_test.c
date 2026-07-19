#include "emuladorgba/rom.h"

#include <assert.h>
#include <stdio.h>
#include <string.h>

static unsigned char header_checksum(const unsigned char* rom) {
  unsigned char checksum = 0u;
  size_t index;
  for (index = 0xA0u; index < 0xBCu; ++index) {
    checksum = (unsigned char)(checksum - rom[index]);
  }
  return (unsigned char)(checksum - 0x19u);
}

int main(void) {
  const char* path = "emuladorgba_test_rom.gba";
  unsigned char rom[0xC0u] = {0};
  emugba_rom_info info;
  FILE* file;

  memcpy(&rom[0xA0u], "POKEMON TEST", 12u);
  memcpy(&rom[0xACu], "TEST", 4u);
  memcpy(&rom[0xB0u], "01", 2u);
  rom[0xBCu] = 1u;
  rom[0xBDu] = header_checksum(rom);

  file = fopen(path, "wb");
  assert(file != NULL);
  assert(fwrite(rom, 1u, sizeof(rom), file) == sizeof(rom));
  assert(fclose(file) == 0);

  assert(emugba_rom_has_supported_extension(path));
  assert(!emugba_rom_has_supported_extension("game.zip"));
  assert(emugba_rom_inspect_file(path, &info) == EMUGBA_OK);
  assert(strcmp(info.title, "POKEMON TEST") == 0);
  assert(strcmp(info.game_code, "TEST") == 0);
  assert(strcmp(info.maker_code, "01") == 0);
  assert(info.file_size == sizeof(rom));
  assert(info.software_version == 1u);
  assert(info.header_checksum_valid);
  assert(strlen(info.sha256) == 64u);

  assert(remove(path) == 0);
  return 0;
}
