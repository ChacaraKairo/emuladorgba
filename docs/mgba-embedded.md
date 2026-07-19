# Integração embarcada do mGBA

## Versão e licença

O projeto fixa o mGBA na versão `0.10.5` por meio do CMake `FetchContent`. O mGBA é distribuído sob MPL-2.0. Alterações em arquivos provenientes do mGBA devem permanecer compatíveis com essa licença; o wrapper do projeto fica separado em `native/`.

## Build nativo

```bash
cmake -S . -B build \
  -DEMULADORGBA_WITH_MGBA=ON \
  -DEMULADORGBA_BUILD_TESTS=ON \
  -DEMULADORGBA_BUILD_CLI=ON
cmake --build build --config Release
ctest --test-dir build -C Release --output-on-failure
```

A biblioteca produzida é:

- Linux: `build/libemuladorgba_core.so`
- Windows: `build/Release/emuladorgba_core.dll`
- macOS: `build/libemuladorgba_core.dylib`

O caminho pode ser sobrescrito no frontend:

```bash
export EMUGBA_CORE_LIBRARY=/caminho/libemuladorgba_core.so
```

## Ciclo da sessão

1. `mCoreFind` escolhe o núcleo GBA para o arquivo.
2. `mCore::init` inicializa CPU, memória, vídeo, áudio e RTC.
3. `mCoreLoadFile` carrega a ROM em modo leitura.
4. `mCoreLoadSaveFile` associa o `.sav` à sessão.
5. `mCore::setVideoBuffer` aponta para um framebuffer nativo 240x160.
6. `mCore::setAVStream` envia PCM estéreo ao ring buffer do wrapper.
7. `mCore::setKeys` recebe o bitmask dos botões.
8. `mCore::runFrame` executa um frame completo.
9. `savedataClone` produz a SRAM atual para gravação atômica.
10. `mCore::deinit` encerra o núcleo e libera os recursos.

## Vídeo

O mGBA produz pixels nativos de 32 bits. O wrapper normaliza cada frame para RGBA8888 e expõe exatamente `240 * 160 * 4` bytes. O Flutter cria uma `ui.Image` e usa `FilterQuality.none` para preservar pixels nítidos.

## Áudio

O callback `postAudioFrame` alimenta um ring buffer de amostras `int16` estéreo. A API `emugba_session_read_audio` drena esse buffer. No Linux, o frontend encaminha o PCM para `aplay` em S16_LE; a ausência do utilitário não interrompe a emulação.

## Entrada

Os índices dos botões seguem o bitmask do GBA:

| Índice | Botão |
|---:|---|
| 0 | A |
| 1 | B |
| 2 | Select |
| 3 | Start |
| 4 | Direita |
| 5 | Esquerda |
| 6 | Cima |
| 7 | Baixo |
| 8 | R |
| 9 | L |

## Saves

O save é carregado no início da sessão e clonado na saída. A gravação usa um arquivo temporário e `rename`, reduzindo a possibilidade de corrupção. A tela externa de gerenciamento continua responsável pelos backups históricos.

## RTC

A sessão usa `RTC_NO_OVERRIDE`, portanto o núcleo utiliza o relógio real do sistema. Isso preserva eventos baseados em horário dos jogos que usam RTC.

## Limitações conhecidas

- saída PCM direta está implementada inicialmente para Linux/ALSA;
- o frontend ainda decodifica uma imagem por frame, abordagem funcional mas não definitiva;
- a renderização futura deve usar textura compartilhada para reduzir cópias;
- testes automatizados não incluem ROMs comerciais; a validação funcional deve usar ROM homebrew ou arquivo legal fornecido pelo usuário.
