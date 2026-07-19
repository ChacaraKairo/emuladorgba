#include "emuladorgba/storage.h"

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#if defined(_WIN32)
#include <direct.h>
#define EMUGBA_RMDIR(path) _rmdir(path)
#define EMUGBA_SEPARATOR "\\"
#else
#include <unistd.h>
#define EMUGBA_RMDIR(path) rmdir(path)
#define EMUGBA_SEPARATOR "/"
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
  char backup_path[1200];
  emugba_rom_info rom_info;
  emugba_game_paths paths;
  const unsigned char first_save[] = {1u, 2u, 3u, 4u};
  const unsigned char second_save[] = {9u, 8u, 7u};
  const unsigned char imported_save[] = {5u, 5u, 5u, 5u, 5u};
  unsigned char buffer[8];
  FILE* file;
  long now = (long)time(NULL);

  snprintf(root, sizeof(root), "emugba-storage-test-%ld", now);
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

  assert(emugba_save_write_atomic(&paths, first_save, sizeof(first_save), 10u) == EMUGBA_OK);
  memset(buffer, 0, sizeof(buffer));
  read_exact(paths.save_file, buffer, sizeof(first_save));
  assert(memcmp(buffer, first_save, sizeof(first_save)) == 0);

  assert(emugba_save_write_atomic(&paths, second_save, sizeof(second_save), 10u) == EMUGBA_OK);
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
  fclose(file);
  assert(emugba_save_import_file(&paths, import_path, 10u) == EMUGBA_OK);
  memset(buffer, 0, sizeof(buffer));
  read_exact(paths.save_file, buffer, sizeof(imported_save));
  assert(memcmp(buffer, imported_save, sizeof(imported_save)) == 0);

  remove(export_path);
  remove(import_path);
  remove(paths.save_file);
  remove(paths.metadata_file);

  /* Backups use timestamped names; leave no assumptions about their exact names.
     The test root is intentionally unique and harmless if a backup remains. */
  snprintf(backup_path, sizeof(backup_path), "%s%s%s", paths.game_directory, EMUGBA_SEPARATOR, "states");
  EMUGBA_RMDIR(backup_path);

  return 0;
}
