#ifndef EMULADORGBA_STORAGE_H
#define EMULADORGBA_STORAGE_H

#include "emuladorgba/core.h"
#include "emuladorgba/rom.h"

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define EMUGBA_PATH_CAPACITY 1024u

typedef struct emugba_game_paths {
  char game_directory[EMUGBA_PATH_CAPACITY];
  char save_file[EMUGBA_PATH_CAPACITY];
  char metadata_file[EMUGBA_PATH_CAPACITY];
  char backups_directory[EMUGBA_PATH_CAPACITY];
  char states_directory[EMUGBA_PATH_CAPACITY];
} emugba_game_paths;

/** Creates the application root and the directories assigned to one ROM hash. */
EMULADORGBA_API emugba_result emugba_storage_prepare_game(
    const char* storage_root,
    const emugba_rom_info* rom_info,
    emugba_game_paths* out_paths);

/** Writes metadata.json for a ROM without copying the ROM itself. */
EMULADORGBA_API emugba_result emugba_storage_write_metadata(
    const emugba_game_paths* paths,
    const char* rom_path,
    const emugba_rom_info* rom_info);

/** Atomically replaces save.sav and preserves the previous file as a backup. */
EMULADORGBA_API emugba_result emugba_save_write_atomic(
    const emugba_game_paths* paths,
    const uint8_t* data,
    size_t size,
    size_t maximum_backups);

/** Imports a normal cartridge save using the same atomic replacement path. */
EMULADORGBA_API emugba_result emugba_save_import_file(
    const emugba_game_paths* paths,
    const char* source_path,
    size_t maximum_backups);

/** Exports the current normal cartridge save to a user-selected path. */
EMULADORGBA_API emugba_result emugba_save_export_file(
    const emugba_game_paths* paths,
    const char* destination_path);

#ifdef __cplusplus
}
#endif

#endif
