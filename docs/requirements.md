# Requisitos

## Requisitos funcionais

### Biblioteca

- RF-001: importar arquivos `.gba` pelo seletor do sistema.
- RF-002: validar extensão, tamanho mínimo e cabeçalho.
- RF-003: calcular SHA-256 sem modificar a ROM.
- RF-004: impedir duplicatas por hash e permitir aliases visuais.
- RF-005: listar, pesquisar, favoritar e remover entradas.
- RF-006: remover uma entrada sem apagar o arquivo original por padrão.

### Emulação

- RF-010: iniciar, pausar, retomar e encerrar uma sessão.
- RF-011: produzir vídeo a 240x160 e áudio sincronizado.
- RF-012: aceitar teclado, gamepad e controles por toque.
- RF-013: oferecer velocidade normal e avanço rápido.
- RF-014: manter RTC de acordo com a configuração do sistema.
- RF-015: funcionar sem BIOS externa quando o núcleo permitir; BIOS opcional deve ser fornecida pelo usuário.

### Saves

- RF-020: carregar e persistir save normal de cartucho.
- RF-021: usar diretório determinado pelo hash da ROM.
- RF-022: gravar de forma atômica usando arquivo temporário.
- RF-023: criar backup antes de substituir ou importar.
- RF-024: exportar e importar `.sav`.
- RF-025: comparar checksum, tamanho e data antes de resolver conflitos.
- RF-026: manter save states separados e versionados pelo núcleo.

### Configuração

- RF-030: configurar diretórios de ROMs, dados e exportação.
- RF-031: mapear controles.
- RF-032: configurar áudio, escala, filtro e velocidade.
- RF-033: selecionar tema e idioma.
- RF-034: restaurar padrões sem apagar jogos ou saves.

## Requisitos não funcionais

- RNF-001: Android, Linux e Windows são plataformas de primeira classe.
- RNF-002: o núcleo deve permanecer atrás de uma API C estável.
- RNF-003: nenhuma ROM, BIOS ou save deve entrar no Git.
- RNF-004: falhas de gravação não podem destruir o último save válido.
- RNF-005: logs não devem conter conteúdo integral de ROM ou save.
- RNF-006: builds de release devem ser reproduzíveis na medida do possível.
- RNF-007: código C deve compilar com warnings como erro.
- RNF-008: operações de arquivo devem tratar caminhos Unicode.
- RNF-009: o aplicativo deve funcionar offline.
- RNF-010: a interface deve ser utilizável por teclado e leitores de tela onde a plataforma permitir.

## Critérios de aceite do MVP

1. Importar uma ROM de teste/homebrew válida.
2. Iniciar e manter 60 FPS no hardware mínimo definido.
3. Fechar e reabrir mantendo o save normal.
4. Exportar o save no desktop e importá-lo no Android.
5. Simular interrupção durante a gravação e recuperar o último backup.
6. Rodar testes unitários e integração em CI.