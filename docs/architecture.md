# Arquitetura inicial

## Objetivo

Construir um aplicativo de emulação de Game Boy Advance focado na experiência de jogos Pokémon, mantendo o núcleo de emulação isolado da interface e do gerenciamento de arquivos.

## Componentes

```text
Aplicativo multiplataforma
├── biblioteca de jogos
├── tela de emulação
├── controles
├── gerenciador de saves
├── backups e conflitos
└── configurações
        ↓
C API estável do projeto
        ↓
Adaptador do núcleo
        ↓
mGBA
```

## Decisões

1. O núcleo será integrado por uma API C pequena e estável.
2. A interface não acessará diretamente estruturas internas do mGBA.
3. Saves de cartucho serão portáveis; save states serão considerados dependentes da versão do núcleo.
4. ROMs serão identificadas por SHA-256 do conteúdo, não apenas pelo nome do arquivo.
5. Escritas de save deverão ser atômicas e acompanhadas de backup.
6. RTC deverá ser preservado para jogos que dependem do relógio.
7. ROMs, BIOS e saves não serão versionados no Git.

## Plataformas-alvo

- Android;
- Linux;
- Windows;
- macOS em etapa posterior.

## Primeira prova de conceito

A primeira entrega executável deverá:

1. inicializar a biblioteca nativa;
2. carregar uma ROM de teste ou homebrew fornecida pelo usuário;
3. produzir frames de vídeo;
4. receber entradas do jogador;
5. carregar e persistir o save de cartucho;
6. encerrar sem corromper o save.

## Limites iniciais

Não fazem parte da primeira prova de conceito:

- multiplayer em rede;
- Wireless Adapter;
- sincronização em nuvem;
- download de ROMs;
- banco de dados online de capas;
- recursos específicos de edição de saves.
