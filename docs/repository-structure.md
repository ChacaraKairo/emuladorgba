# Estrutura do repositório

```text
emuladorgba/
├── apps/
│   ├── cli/                    # Ferramentas de diagnóstico
│   └── frontend_flutter/       # Android, Linux e Windows
├── native/
│   ├── include/emuladorgba/    # API C pública e estável
│   ├── src/                    # Wrapper, ROM, saves e adaptadores
│   ├── third_party/            # Dependências fixadas ou submódulos
│   └── cmake/                  # Módulos auxiliares de build
├── packages/
│   ├── game_library/           # Regras de biblioteca
│   ├── save_manager/           # Importação, backup e conflitos
│   └── sync_protocol/          # Modelo de sincronização
├── tests/
│   ├── unit/
│   ├── integration/
│   ├── fixtures/               # Somente dados sintéticos/homebrew permitidos
│   └── compatibility/
├── docs/
│   ├── adr/
│   └── ...
├── scripts/                    # Build, lint, empacotamento e auditoria
├── .github/workflows/
├── CMakeLists.txt
└── README.md
```

## Regras de dependência

- O Flutter depende apenas da API pública e dos serviços de domínio.
- A API pública não expõe tipos internos do mGBA.
- `save_manager` não depende da interface.
- `game_library` pode inspecionar ROMs, mas não inicia emulação.
- O backend mGBA implementa uma interface interna substituível.
- Testes não podem exigir ROM comercial.

## Convenções

- C: `snake_case`, prefixo público `emugba_`.
- Dart: convenções oficiais do Dart/Flutter.
- Arquivos Markdown: nomes em inglês, conteúdo em português.
- Branches: `feature/`, `fix/`, `docs/` ou `agent/`.
- Commits: ação curta e escopo claro.

## Artefatos ignorados

Devem permanecer fora do Git:

- `*.gba`, `*.gb`, `*.gbc`;
- BIOS;
- `*.sav`, `*.srm`, save states;
- capturas privadas;
- diretórios de dados do usuário;
- chaves e credenciais;
- binários de build.