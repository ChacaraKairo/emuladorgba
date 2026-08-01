# Plataformas

## Android

- arquitetura mínima inicial: ARM64;
- integração nativa via Android NDK e Dart FFI;
- seleção de ROMs pelo Storage Access Framework;
- persistência de permissões quando disponível;
- dados internos em diretório privado do aplicativo;
- sessões devem reagir a pausa, suspensão, perda de áudio e encerramento;
- controles por toque e gamepads Bluetooth/USB;
- não exigir acesso amplo ao armazenamento.

## Linux

- alvo primário de desenvolvimento: Kubuntu/Ubuntu;
- áudio e janela providos pelo Flutter e plugins escolhidos;
- suporte a Wayland e X11 conforme toolchain Flutter;
- diretórios segundo XDG quando aplicável;
- empacotamento inicial AppImage ou pacote equivalente após validação.

## Windows

- build com MSVC;
- suporte a caminhos Unicode;
- gamepads por APIs expostas pelos plugins escolhidos;
- dados em diretório de aplicação do usuário;
- instalador não deve exigir privilégios administrativos sem necessidade.

## macOS e iOS

Fora do MVP, mas a API deve evitar decisões que impeçam suporte futuro. Distribuição em plataformas Apple exige revisão específica de toolchain, assinatura e políticas da loja.

## Matriz mínima

| Recurso | Android | Linux | Windows |
|---|---|---|---|
| Importar `.gba` | obrigatório | obrigatório | obrigatório |
| Save normal | obrigatório | obrigatório | obrigatório |
| Exportar/importar `.sav` | obrigatório | obrigatório | obrigatório |
| Teclado | opcional | obrigatório | obrigatório |
| Toque | obrigatório | não aplicável | opcional |
| Gamepad | obrigatório | obrigatório | obrigatório |
| RTC | obrigatório | obrigatório | obrigatório |
| Save states | pós-MVP | pós-MVP | pós-MVP |

## Hardware mínimo

Os requisitos finais serão definidos após benchmarks. Como referência inicial:

- CPU de 64 bits com desempenho suficiente para 60 FPS;
- 2 GB de RAM no Android e 4 GB no desktop;
- armazenamento livre para aplicativo, cache, backups e ROMs gerenciadas;
- GPU compatível com a versão mínima suportada pelo Flutter.

Esses valores são provisórios e não devem ser publicados como promessa antes dos testes.