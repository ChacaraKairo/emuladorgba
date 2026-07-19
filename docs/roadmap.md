# Roadmap

## Fase 0 — Fundação

- documentação e ADRs;
- API C inicial;
- inspeção de ROM e SHA-256;
- CMake, testes sintéticos e CI mínima;
- revisão de licenças.

**Saída:** biblioteca nativa compilável e documentação aprovada.

## Fase 1 — Biblioteca e saves

- catálogo local de ROMs;
- armazenamento referenciado e gerenciado;
- diretórios por hash;
- save manager com gravação atômica;
- backups, importação e exportação;
- CLI de diagnóstico.

**Saída:** ROMs e saves podem ser administrados sem iniciar emulação.

## Fase 2 — Backend mGBA

- dependência fixada;
- adaptador de ciclo de vida;
- execução de frames;
- framebuffer e áudio;
- entrada por bitmask;
- SRAM/EEPROM/Flash e RTC;
- flush seguro ao encerrar.

**Saída:** homebrew e ROM local executam em aplicação de teste.

## Fase 3 — Frontend desktop

- Flutter para Linux e Windows;
- biblioteca, tela de jogo e configurações;
- teclado, gamepad, áudio e tela cheia;
- gerenciamento visual de saves.

**Saída:** alpha desktop utilizável.

## Fase 4 — Android

- FFI/NDK;
- seletor de documentos e permissões persistentes;
- controles virtuais;
- áudio e ciclo de vida mobile;
- testes de suspensão, retomada e bateria.

**Saída:** alpha Android com saves compatíveis com desktop.

## Fase 5 — Qualidade Pokémon

- matriz de jogos e regiões mantida fora do Git quando necessário;
- testes de Flash 128 KiB e RTC;
- compatibilidade com patches e ROM hacks legais;
- diagnósticos específicos de save;
- polimento de avanço rápido e controles.

**Saída:** beta focada em Pokémon.

## Fase 6 — Sincronização

- pacote `.egsave`;
- pasta sincronizada;
- revisão e conflitos;
- histórico de backups;
- nuvem própria apenas após avaliação.

**Saída:** continuidade segura entre dispositivos.

## Fase 7 — Recursos avançados

- save states e screenshots;
- rewind;
- shaders;
- link local;
- multiplayer de rede somente após prova técnica;
- automações e recursos opcionais específicos de Pokémon.

## Definição de pronto

Uma fase só termina com documentação atualizada, testes automatizados, critérios de aceite atendidos e ausência de dados protegidos no repositório.