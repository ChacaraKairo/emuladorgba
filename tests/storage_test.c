#include "emuladorgba/storage.h"

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#if defined(_WIN32)
#include <direct.h>
#include <process.h>
#define EMUGBA_GETPID() _getpid()
#define EMUGBA_RMDIR(path) _rmdir(path)
#else
#include <unistd.h>
#define EMUGBA_GETPID() getpid()
#define EMUGBA_RMDIR(path) rmdir(path)
#endif

static void read_exact(const char* path, unsigned char* output, size_t size) {
  FILE* file = fopen(path, "rb");
  assert(file != NULL);
  assert(fread(output, 1u, size, file) == size);
  assert(fgetc(file) == EOF);
  fclose(file);
}

int main(void) {
  char root[256];
  char export_path[320];
  char import_path[320];
  emugba_rom_info rom_info;
  emugba_game_paths paths;
  const unsigned char first_save[] = {1u, 2u, 3u, 4u};
  const unsigned char second_save[] = {9u, 8u, 7u};
  const unsigned char imported_save[] = {5u, 5u, 5u, 5u, 5u};
  unsigned char buffer[8];
  FILE* file;
  const long now = (long)time(NULL);
  const long process_id = (long)EMUGBA_GETPID();

  snprintf(root, sizeof(root), "emugba-storage-test-%ld-%ld", now, process_id);
  snprintf(export_path, sizeof(export_path), "%s-export.sav", root);
  snprintf(import_path, sizeof(import_path), "%s-import.sav", root);

  memset(&rom_info, 0, sizeof(rom_info));
  strcpy(rom_info.title, "TEST GAME");
  strcpy(rom_info.game_code, "TGME");
  strcpy(rom_info.maker_code, "01");
  strcpy(rom_info.sha256, "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef");
  rom_info.file_size = 1024u;
  rom_info.header_checksum_valid = 1;

  assert(emugba_storage_prepare_game(root, &rom_info, &paths) == EMUGBA_OK);
  assert(strstr(paths.game_directory, rom_info.sha256) != NULL);
  assert(emugba_storage_write_metadata(&paths, "games/test.gba", &rom_info) == EMUGBA_OK);

  assert(emugba_save_write_atomic(&paths, first_save, sizeof(first_save), 0u) == EMUGBA_OK);
  memset(buffer, 0, sizeof(buffer));
  read_exact(paths.save_file, buffer, sizeof(first_save));
  assert(memcmp(buffer, first_save, sizeof(first_save)) == 0);

  assert(emugba_save_write_atomic(&paths, second_save, sizeof(second_save), 0u) == EMUGBA_OK);
  memset(buffer, 0, sizeof(buffer));
  read_exact(paths.save_file, buffer, sizeof(second_save));
  assert(memcmp(buffer, second_save, sizeof(second_save)) == 0);

  assert(emugba_save_export_file(&paths, export_path) == EMUGBA_OK);
  memset(buffer, 0, sizeof(buffer));
  read_exact(export_path, buffer, sizeof(second_save));
  assert(memcmp(buffer, second_save, sizeof(second_save)) == 0);

  file = fopen(import_path, "wb");
  assert(file != NULL);
  assert(fwrite(imported_save, 1u, sizeof(imported_save), file) == sizeof(imported_save));
  assert(fclose(file) == 0);
  assert(emugba_save_import_file(&paths, import_path, 0u) == EMUGBA_OK);
  memset(buffer, 0, sizeof(buffer));
  read_exact(paths.save_file, buffer, sizeof(imported_save));
  assert(memcmp(buffer, imported_save, sizeof(imported_save)) == 0);

  assert(remove(export_path) == 0);
  assert(remove(import_path) == 0);
  assert(remove(paths.save_file) == 0);
  assert(remove(paths.metadata_file) == 0);
  assert(EMUGBA_RMDIR(paths.states_directory) == 0);
  assert(EMUGBA_RMDIR(paths.backups_directory) == 0);
  assert(EMUGBA_RMDIR(paths.game_directory) == 0);

  {
    char games_directory[320];
    snprintf(games_directory, sizeof(games_directory), "%s/games", root);
    assert(EMUGBA_RMDIR(games_directory) == 0);
  }
  assert(EMUGBA_RMDIR(root) == 0);

  return 0;
}
