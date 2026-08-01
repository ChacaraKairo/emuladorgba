# Formato e ciclo de vida dos saves

## Tipos de salvamento

### Save de cartucho

É o salvamento criado pelo próprio jogo. Será o formato principal para compartilhamento entre dispositivos.

Extensão canônica interna:

```text
game.sav
```

A importação poderá aceitar `.sav` e `.srm`, desde que tamanho e compatibilidade sejam validados.

### Save state

Representa o estado completo do emulador. Não possui garantia de compatibilidade entre versões diferentes do núcleo e não será usado como mecanismo principal de sincronização.

## Organização por jogo

```text
runtime/
└── games/
    └── <rom-sha256>/
        ├── game.json
        ├── saves/
        │   ├── game.sav
        │   └── backups/
        ├── states/
        └── screenshots/
```

## Metadados

Exemplo de `game.json`:

```json
{
  "schemaVersion": 1,
  "gameId": "sha256-da-rom",
  "title": "Título detectado",
  "romFileName": "arquivo.gba",
  "save": {
    "sizeBytes": 131072,
    "sha256": "sha256-do-save",
    "updatedAt": "2026-07-18T00:00:00Z",
    "updatedBy": "device-id"
  },
  "core": {
    "name": "mGBA",
    "version": "a-definir"
  }
}
```

## Escrita atômica

Nunca sobrescrever diretamente `game.sav`.

1. gravar `game.sav.tmp`;
2. forçar a sincronização dos dados no disco quando a plataforma permitir;
3. validar tamanho e hash;
4. copiar o save atual para `backups/`;
5. renomear atomicamente o temporário para `game.sav`;
6. atualizar os metadados.

## Conflitos

Um conflito existe quando duas versões descendem do mesmo save conhecido, mas possuem hashes diferentes.

A interface deverá oferecer:

- manter a versão local;
- usar a versão externa;
- guardar ambas;
- cancelar sem modificar arquivos.

## Regras de segurança

- criar backup antes de importar ou substituir;
- limitar a quantidade de backups por configuração;
- rejeitar arquivos vazios;
- não confiar apenas na extensão;
- associar o save ao SHA-256 da ROM;
- registrar versão do núcleo para save states;
- preservar dados auxiliares de RTC quando exigidos pelo núcleo.
