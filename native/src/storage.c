#include "emuladorgba/storage.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#if defined(_WIN32)
#include <direct.h>
#define EMUGBA_MKDIR(path) _mkdir(path)
#define EMUGBA_PATH_SEPARATOR '\\'
#else
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#define EMUGBA_MKDIR(path) mkdir(path, 0755)
#define EMUGBA_PATH_SEPARATOR '/'
#endif

static int path_exists(const char* path) {
  FILE* file = fopen(path, "rb");
  if (file != NULL) {
    fclose(file);
    return 1;
  }
  return 0;
}

static emugba_result copy_text(char* output, size_t capacity, const char* input) {
  const size_t length = strlen(input);
  if (length + 1u > capacity) {
    return EMUGBA_ERROR_INVALID_ARGUMENT;
  }
  memcpy(output, input, length + 1u);
  return EMUGBA_OK;
}

static emugba_result join_path(
    char* output,
    size_t capacity,
    const char* left,
    const char* right) {
  const size_t left_length = strlen(left);
  const int needs_separator =
      left_length > 0u && left[left_length - 1u] != '/' && left[left_length - 1u] != '\\';
  const int written = snprintf(
      output,
      capacity,
      needs_separator ? "%s%c%s" : "%s%s",
      left,
      EMUGBA_PATH_SEPARATOR,
      right);
  return written < 0 || (size_t)written >= capacity
      ? EMUGBA_ERROR_INVALID_ARGUMENT
      : EMUGBA_OK;
}

static emugba_result ensure_directory(const char* path) {
  char buffer[EMUGBA_PATH_CAPACITY];
  size_t index;
  emugba_result result = copy_text(buffer, sizeof(buffer), path);
  if (result != EMUGBA_OK) {
    return result;
  }

  for (index = 1u; buffer[index] != '\0'; ++index) {
    if (buffer[index] == '/' || buffer[index] == '\\') {
      const char original = buffer[index];
      buffer[index] = '\0';
#if defined(_WIN32)
      if (!(index == 2u && buffer[1] == ':')) {
#endif
        if (EMUGBA_MKDIR(buffer) != 0 && errno != EEXIST) {
          return EMUGBA_ERROR_IO;
        }
#if defined(_WIN32)
      }
#endif
      buffer[index] = original;
    }
  }

  if (EMUGBA_MKDIR(buffer) != 0 && errno != EEXIST) {
    return EMUGBA_ERROR_IO;
  }
  return EMUGBA_OK;
}

static emugba_result copy_file(const char* source_path, const char* destination_path) {
  FILE* source;
  FILE* destination;
  unsigned char buffer[65536];
  size_t bytes_read;

  source = fopen(source_path, "rb");
  if (source == NULL) {
    return errno == ENOENT ? EMUGBA_ERROR_FILE_NOT_FOUND : EMUGBA_ERROR_IO;
  }
  destination = fopen(destination_path, "wb");
  if (destination == NULL) {
    fclose(source);
    return EMUGBA_ERROR_IO;
  }

  while ((bytes_read = fread(buffer, 1u, sizeof(buffer), source)) > 0u) {
    if (fwrite(buffer, 1u, bytes_read, destination) != bytes_read) {
      fclose(destination);
      fclose(source);
      remove(destination_path);
      return EMUGBA_ERROR_IO;
    }
  }

  if (ferror(source) || fflush(destination) != 0) {
    fclose(destination);
    fclose(source);
    remove(destination_path);
    return EMUGBA_ERROR_IO;
  }

  fclose(destination);
  fclose(source);
  return EMUGBA_OK;
}

static void escape_json(FILE* file, const char* value) {
  const unsigned char* cursor = (const unsigned char*)value;
  while (*cursor != 0u) {
    switch (*cursor) {
      case '\\': fputs("\\\\", file); break;
      case '"': fputs("\\\"", file); break;
      case '\n': fputs("\\n", file); break;
      case '\r': fputs("\\r", file); break;
      case '\t': fputs("\\t", file); break;
      default:
        if (*cursor >= 0x20u) {
          fputc((int)*cursor, file);
        }
        break;
    }
    ++cursor;
  }
}

static emugba_result make_backup(
    const emugba_game_paths* paths,
    size_t maximum_backups) {
  char backup_path[EMUGBA_PATH_CAPACITY];
  time_t now;
  struct tm* local;
  char stamp[32];
  size_t sequence;

  if (!path_exists(paths->save_file) || maximum_backups == 0u) {
    return EMUGBA_OK;
  }

  now = time(NULL);
  local = localtime(&now);
  if (local == NULL || strftime(stamp, sizeof(stamp), "%Y%m%d-%H%M%S", local) == 0u) {
    return EMUGBA_ERROR_IO;
  }

  for (sequence = 0u; sequence < maximum_backups; ++sequence) {
    char filename[96];
    const int written = snprintf(filename, sizeof(filename), "%s-%03u.sav", stamp, (unsigned)sequence);
    if (written < 0 || (size_t)written >= sizeof(filename)) {
      return EMUGBA_ERROR_IO;
    }
    if (join_path(backup_path, sizeof(backup_path), paths->backups_directory, filename) != EMUGBA_OK) {
      return EMUGBA_ERROR_INVALID_ARGUMENT;
    }
    if (!path_exists(backup_path)) {
      return copy_file(paths->save_file, backup_path);
    }
  }

  return EMUGBA_ERROR_IO;
}

emugba_result emugba_storage_prepare_game(
    const char* storage_root,
    const emugba_rom_info* rom_info,
    emugba_game_paths* out_paths) {
  char games_directory[EMUGBA_PATH_CAPACITY];
  emugba_result result;

  if (storage_root == NULL || rom_info == NULL || out_paths == NULL ||
      storage_root[0] == '\0' || strlen(rom_info->sha256) != 64u) {
    return EMUGBA_ERROR_INVALID_ARGUMENT;
  }

  memset(out_paths, 0, sizeof(*out_paths));
  result = ensure_directory(storage_root);
  if (result != EMUGBA_OK) return result;
  result = join_path(games_directory, sizeof(games_directory), storage_root, "games");
  if (result != EMUGBA_OK) return result;
  result = ensure_directory(games_directory);
  if (result != EMUGBA_OK) return result;
  result = join_path(out_paths->game_directory, sizeof(out_paths->game_directory), games_directory, rom_info->sha256);
  if (result != EMUGBA_OK) return result;
  result = ensure_directory(out_paths->game_directory);
  if (result != EMUGBA_OK) return result;
  result = join_path(out_paths->backups_directory, sizeof(out_paths->backups_directory), out_paths->game_directory, "backups");
  if (result != EMUGBA_OK) return result;
  result = ensure_directory(out_paths->backups_directory);
  if (result != EMUGBA_OK) return result;
  result = join_path(out_paths->states_directory, sizeof(out_paths->states_directory), out_paths->game_directory, "states");
  if (result != EMUGBA_OK) return result;
  result = ensure_directory(out_paths->states_directory);
  if (result != EMUGBA_OK) return result;
  result = join_path(out_paths->save_file, sizeof(out_paths->save_file), out_paths->game_directory, "save.sav");
  if (result != EMUGBA_OK) return result;
  return join_path(out_paths->metadata_file, sizeof(out_paths->metadata_file), out_paths->game_directory, "metadata.json");
}

emugba_result emugba_storage_write_metadata(
    const emugba_game_paths* paths,
    const char* rom_path,
    const emugba_rom_info* rom_info) {
  char temporary_path[EMUGBA_PATH_CAPACITY];
  FILE* file;
  int written;

  if (paths == NULL || rom_path == NULL || rom_info == NULL) {
    return EMUGBA_ERROR_INVALID_ARGUMENT;
  }
  written = snprintf(temporary_path, sizeof(temporary_path), "%s.tmp", paths->metadata_file);
  if (written < 0 || (size_t)written >= sizeof(temporary_path)) {
    return EMUGBA_ERROR_INVALID_ARGUMENT;
  }

  file = fopen(temporary_path, "wb");
  if (file == NULL) return EMUGBA_ERROR_IO;
  fputs("{\n  \"schemaVersion\": 1,\n  \"romPath\": \"", file);
  escape_json(file, rom_path);
  fputs("\",\n  \"title\": \"", file);
  escape_json(file, rom_info->title);
  fputs("\",\n  \"gameCode\": \"", file);
  escape_json(file, rom_info->game_code);
  fputs("\",\n  \"makerCode\": \"", file);
  escape_json(file, rom_info->maker_code);
  fprintf(file,
      "\",\n  \"sha256\": \"%s\",\n  \"fileSize\": %llu,\n  \"softwareVersion\": %u,\n  \"headerChecksumValid\": %s\n}\n",
      rom_info->sha256,
      (unsigned long long)rom_info->file_size,
      (unsigned)rom_info->software_version,
      rom_info->header_checksum_valid ? "true" : "false");

  if (ferror(file) || fflush(file) != 0 || fclose(file) != 0) {
    remove(temporary_path);
    return EMUGBA_ERROR_IO;
  }
  remove(paths->metadata_file);
  if (rename(temporary_path, paths->metadata_file) != 0) {
    remove(temporary_path);
    return EMUGBA_ERROR_IO;
  }
  return EMUGBA_OK;
}

emugba_result emugba_save_write_atomic(
    const emugba_game_paths* paths,
    const uint8_t* data,
    size_t size,
    size_t maximum_backups) {
  char temporary_path[EMUGBA_PATH_CAPACITY];
  FILE* file;
  int written;
  emugba_result result;

  if (paths == NULL || data == NULL || size == 0u) {
    return EMUGBA_ERROR_INVALID_ARGUMENT;
  }
  result = make_backup(paths, maximum_backups);
  if (result != EMUGBA_OK) return result;

  written = snprintf(temporary_path, sizeof(temporary_path), "%s.tmp", paths->save_file);
  if (written < 0 || (size_t)written >= sizeof(temporary_path)) {
    return EMUGBA_ERROR_INVALID_ARGUMENT;
  }
  file = fopen(temporary_path, "wb");
  if (file == NULL) return EMUGBA_ERROR_IO;
  if (fwrite(data, 1u, size, file) != size || fflush(file) != 0 || fclose(file) != 0) {
    remove(temporary_path);
    return EMUGBA_ERROR_IO;
  }
  remove(paths->save_file);
  if (rename(temporary_path, paths->save_file) != 0) {
    remove(temporary_path);
    return EMUGBA_ERROR_IO;
  }
  return EMUGBA_OK;
}

emugba_result emugba_save_import_file(
    const emugba_game_paths* paths,
    const char* source_path,
    size_t maximum_backups) {
  FILE* file;
  long file_size;
  uint8_t* data;
  size_t bytes_read;
  emugba_result result;

  if (paths == NULL || source_path == NULL || source_path[0] == '\0') {
    return EMUGBA_ERROR_INVALID_ARGUMENT;
  }
  file = fopen(source_path, "rb");
  if (file == NULL) return errno == ENOENT ? EMUGBA_ERROR_FILE_NOT_FOUND : EMUGBA_ERROR_IO;
  if (fseek(file, 0, SEEK_END) != 0 || (file_size = ftell(file)) <= 0 || fseek(file, 0, SEEK_SET) != 0) {
    fclose(file);
    return EMUGBA_ERROR_IO;
  }
  data = (uint8_t*)malloc((size_t)file_size);
  if (data == NULL) {
    fclose(file);
    return EMUGBA_ERROR_OUT_OF_MEMORY;
  }
  bytes_read = fread(data, 1u, (size_t)file_size, file);
  fclose(file);
  if (bytes_read != (size_t)file_size) {
    free(data);
    return EMUGBA_ERROR_IO;
  }
  result = emugba_save_write_atomic(paths, data, bytes_read, maximum_backups);
  free(data);
  return result;
}

emugba_result emugba_save_export_file(
    const emugba_game_paths* paths,
    const char* destination_path) {
  if (paths == NULL || destination_path == NULL || destination_path[0] == '\0') {
    return EMUGBA_ERROR_INVALID_ARGUMENT;
  }
  return copy_file(paths->save_file, destination_path);
}
