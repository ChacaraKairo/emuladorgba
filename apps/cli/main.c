#include "emuladorgba/core.h"
#include "emuladorgba/rom.h"

#include <inttypes.h>
#include <stdio.h>

static void print_usage(const char* executable) {
  fprintf(stderr, "Uso: %s <arquivo.gba>\n", executable);
}

int main(int argc, char** argv) {
  emugba_result result;
  emugba_rom_info info;

  if (argc != 2) {
    print_usage(argv[0]);
    return 2;
  }

  result = emugba_initialize();
  if (result != EMUGBA_OK) {
    fprintf(stderr, "Falha ao inicializar: %s\n", emugba_result_message(result));
    return 1;
  }

  result = emugba_rom_inspect_file(argv[1], &info);
  if (result != EMUGBA_OK) {
    fprintf(stderr, "Falha ao abrir ROM: %s\n", emugba_result_message(result));
    emugba_shutdown();
    return 1;
  }

  printf("Título: %s\n", info.title[0] != '\0' ? info.title : "(sem título)");
  printf("Código do jogo: %s\n", info.game_code);
  printf("Fabricante: %s\n", info.maker_code);
  printf("Tamanho: %" PRIu64 " bytes\n", info.file_size);
  printf("Versão: %u\n", (unsigned int)info.software_version);
  printf("SHA-256: %s\n", info.sha256);
  printf("Checksum do cabeçalho: %s\n",
      info.header_checksum_valid ? "válido" : "inválido");

  emugba_shutdown();
  return info.header_checksum_valid ? 0 : 3;
}
