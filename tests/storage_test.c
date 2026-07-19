#include "emuladorgba/storage.h"

#include <stdio.h>
#include <string.h>
#include <time.h>

#if defined(_WIN32)
#include <direct.h>
#include <process.h>
#define EMUGBA_GETPID() _getpid()
#define EMUGBA_RMDIR(path) _rmdir(path)
#define EMUGBA_SEPARATOR "\\"
#else
#include <unistd.h>
#define EMUGBA_GETPID() getpid()
#define EMUGBA_RMDIR(path) rmdir(path)
#define EMUGBA_SEPARATOR "/"
#endif

#define CHECK(expression) \
  do { \
    if (!(expression)) { \
      fprintf(stderr, "Check failed at %s:%d: %s\n", __FILE__, __LINE__, #expression); \
      return 1; \
    } \
  } while (0)

static int read_exact(const char* path, unsigned char* output, size_t size) {
  FILE* file = fopen(path, "rb");
  if (file == NULL) return 0;
  if (fread(output, 1u, size, file) != size) {
    fclose(file);
    return 0;
  }
  if (fgetc(file) != EOF) {
    fclose(file);
    return 0;
  }
  return fclose(file) == 0;
}

int main(void) {
  char root[256];
  char export_path[320];
  char import_path[320];
  char games_directory[320];
  emugba_rom_info rom_info;
  emugba_game_paths paths;
  const unsigned char first_save[] = {1u, 2u, 3u, 4u};
  const unsigned char second_save[] = {9u, 8u, 7u};
  const unsigned char imported_save[] = {5u, 5u, 5u, 5u, 5u};
  unsigned char buffer[8];
  FILE* file;
  const long now = (long)time(NULL);
  const long process_id = (long)EMUGBA_GETPID();

  CHECK(snprintf(root, sizeof(root), "emugba-storage-test-%ld-%ld", now, process_id) > 0);
  CHECK(snprintf(export_path, sizeof(export_path), "%s-export.sav", root) > 0);
  CHECK(snprintf(import_path, sizeof(import_path), "%s-import.sav", root) > 0);
  CHECK(snprintf(
      games_directory,
      sizeof(games_directory),
      "%s%s%s",
      root,
      EMUGBA_SEPARATOR,
      "games") > 0);

  memset(&rom_info, 0, sizeof(rom_info));
  memcpy(rom_info.title, "TEST GAME", sizeof("TEST GAME"));
  memcpy(rom_info.game_code, "TGME", sizeof("TGME"));
  memcpy(rom_info.maker_code, "01", sizeof("01"));
  memcpy(
      rom_info.sha256,
      "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
      sizeof("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"));
  rom_info.file_size = 1024u;
  rom_info.header_checksum_valid = 1;

  CHECK(emugba_storage_prepare_game(root, &rom_info, &paths) == EMUGBA_OK);
  CHECK(strstr(paths.game_directory, rom_info.sha256) != NULL);
  CHECK(emugba_storage_write_metadata(&paths, "games/test.gba", &rom_info) == EMUGBA_OK);

  CHECK(emugba_save_write_atomic(&paths, first_save, sizeof(first_save), 0u) == EMUGBA_OK);
  memset(buffer, 0, sizeof(buffer));
  CHECK(read_exact(paths.save_file, buffer, sizeof(first_save)));
  CHECK(memcmp(buffer, first_save, sizeof(first_save)) == 0);

  CHECK(emugba_save_write_atomic(&paths, second_save, sizeof(second_save), 0u) == EMUGBA_OK);
  memset(buffer, 0, sizeof(buffer));
  CHECK(read_exact(paths.save_file, buffer, sizeof(second_save)));
  CHECK(memcmp(buffer, second_save, sizeof(second_save)) == 0);

  CHECK(emugba_save_export_file(&paths, export_path) == EMUGBA_OK);
  memset(buffer, 0, sizeof(buffer));
  CHECK(read_exact(export_path, buffer, sizeof(second_save)));
  CHECK(memcmp(buffer, second_save, sizeof(second_save)) == 0);

  file = fopen(import_path, "wb");
  CHECK(file != NULL);
  CHECK(fwrite(imported_save, 1u, sizeof(imported_save), file) == sizeof(imported_save));
  CHECK(fclose(file) == 0);
  CHECK(emugba_save_import_file(&paths, import_path, 0u) == EMUGBA_OK);
  memset(buffer, 0, sizeof(buffer));
  CHECK(read_exact(paths.save_file, buffer, sizeof(imported_save)));
  CHECK(memcmp(buffer, imported_save, sizeof(imported_save)) == 0);

  CHECK(remove(export_path) == 0);
  CHECK(remove(import_path) == 0);
  CHECK(remove(paths.save_file) == 0);
  CHECK(remove(paths.metadata_file) == 0);
  CHECK(EMUGBA_RMDIR(paths.states_directory) == 0);
  CHECK(EMUGBA_RMDIR(paths.backups_directory) == 0);
  CHECK(EMUGBA_RMDIR(paths.game_directory) == 0);
  CHECK(EMUGBA_RMDIR(games_directory) == 0);
  CHECK(EMUGBA_RMDIR(root) == 0);

  return 0;
}
