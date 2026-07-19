# Versão jogável de desktop

Esta etapa permite importar arquivos `.gba` no frontend Flutter e iniciar o jogo usando uma instalação local oficial do mGBA.

## Objetivo

Disponibilizar um fluxo jogável enquanto o backend mGBA embarcado e a integração por FFI continuam em desenvolvimento.

## Plataformas desta etapa

- Linux, incluindo Kubuntu;
- Windows, quando `mgba-qt.exe` ou `mgba.exe` estiver disponível no PATH.

## Dependências no Kubuntu

O frontend detecta automaticamente uma das opções abaixo:

1. Flatpak `io.mgba.mGBA`;
2. executável `mgba-qt`;
3. executável `mgba`.

Para confirmar uma instalação Flatpak:

```bash
flatpak info io.mgba.mGBA
```

## Executar o frontend

```bash
cd apps/frontend_flutter
flutter pub get
flutter run -d linux
```

## Fluxo do usuário

1. abrir o aplicativo;
2. selecionar **Importar ROM**;
3. escolher um arquivo `.gba` obtido legalmente;
4. pressionar **Jogar**;
5. o frontend inicia o mGBA com a ROM selecionada.

A ROM não é copiada, modificada ou apagada pelo aplicativo. A remoção de um item afeta somente a biblioteca local.

## Controles padrão do mGBA

- direcional: setas;
- A: `X`;
- B: `Z`;
- L: `A`;
- R: `S`;
- Start: `Enter`;
- Select: `Backspace`.

## Limitação desta etapa

A janela de jogo ainda pertence ao frontend oficial do mGBA. A próxima arquitetura substituirá esse lançamento externo por um backend embarcado, permitindo que vídeo, áudio, controles e saves sejam gerenciados dentro do aplicativo Flutter.
