# Catálogo, armazenamento e experiência do emulador

## Objetivo

A tela inicial do EmuladorGBA deve funcionar como uma biblioteca visual dos jogos de Game Boy Advance armazenados localmente. O aplicativo deve administrar pastas próprias para ROMs, saves, save states, capas, metadados, configurações e logs, sem distribuir conteúdo protegido.

## Princípios

- o usuário fornece ROMs `.gba` obtidas legalmente;
- a biblioteca é o destaque da página inicial;
- colocar uma ROM na pasta de jogos deve fazê-la aparecer no catálogo;
- saves normais e save states são recursos distintos;
- o último jogo e a última sessão devem poder ser retomados rapidamente;
- teclado, gamepad, velocidade, áudio e vídeo devem ser configuráveis;
- operações de saves devem ser atômicas e criar backups;
- caminhos devem funcionar em Linux, Windows e Android.

## Estrutura gerenciada

O aplicativo cria a seguinte estrutura dentro do diretório de dados escolhido pelo usuário ou do diretório padrão da plataforma:

```text
EmuladorGBA/
├── jogos/
│   └── gba/
├── saves/
│   └── <sha256-da-rom>/
│       ├── save.sav
│       └── backups/
├── savestates/
│   └── <sha256-da-rom>/
│       ├── automatico.state
│       ├── rapido.state
│       └── slots/
├── capas/
├── metadados/
│   ├── biblioteca.json
│   └── ultima-sessao.json
├── configuracoes/
│   ├── emulador.json
│   ├── teclado.json
│   └── controles.json
└── logs/
```

A ROM original deve permanecer intacta. Quando o usuário escolhe importar uma ROM, o aplicativo copia o arquivo para `jogos/gba` com confirmação em caso de conflito.

## Identidade dos jogos

Cada ROM é identificada pelo SHA-256 do conteúdo, não pelo nome do arquivo. Essa identidade associa o jogo aos seus saves, save states, capas, favoritos, tempo jogado e configurações específicas.

## Inicialização e atualização do catálogo

Ao iniciar e quando o usuário selecionar **Atualizar biblioteca**, o aplicativo deve:

1. garantir que todos os diretórios gerenciados existam;
2. procurar arquivos `.gba` dentro de `jogos/gba`;
3. calcular o SHA-256 de ROMs novas ou alteradas;
4. ler título e código do cabeçalho quando possível;
5. preservar metadados existentes;
6. associar save, backups e save states;
7. remover do catálogo entradas cujo arquivo não existe mais, sem apagar saves;
8. ordenar inicialmente por uso recente.

## Página inicial

A página inicial contém, nesta ordem:

1. **Continuar jogando** — cartão destacado do último jogo executado;
2. **Carregar último save state** — disponível quando existir estado válido;
3. **Minha biblioteca** — grade ou lista responsiva com todos os jogos;
4. pesquisa, filtros e ordenação;
5. botão **Adicionar jogo**;
6. acesso a saves, controles e configurações.

### Cartão de jogo

Cada cartão deve mostrar:

- capa ou ilustração substituta;
- título;
- última execução;
- presença de save normal;
- presença de save state;
- favorito;
- botão `Jogar` ou `Continuar`.

### Filtros

- todos;
- recentes;
- favoritos;
- nunca jogados;
- com save;
- com save state.

### Ordenação

- mais recentes;
- título A–Z;
- título Z–A;
- adicionados recentemente;
- mais jogados.

## Adição de jogos

O botão **Adicionar jogo** oferece:

- selecionar um arquivo `.gba`;
- copiar o arquivo para a pasta gerenciada;
- abrir a pasta de jogos no desktop;
- atualizar a biblioteca.

O projeto não deve incluir links ou mecanismos voltados à obtenção não autorizada de ROMs comerciais. Uma futura seção de descoberta pode listar apenas jogos homebrew, demos ou conteúdos distribuídos legalmente.

## Saves normais

O save normal representa a memória persistente do cartucho e deve ficar em:

```text
saves/<sha256-da-rom>/save.sav
```

Requisitos:

- restauração antes de iniciar o jogo;
- captura ao encerrar a sessão;
- gravação atômica;
- backup antes de substituir;
- importação e exportação;
- limite de backups configurável;
- compatibilidade entre plataformas sempre que o núcleo permitir.

## Save states

Save state é um instantâneo do núcleo de emulação e não substitui o save normal.

Recursos previstos:

- estado rápido;
- carregamento rápido;
- estado automático ao fechar;
- múltiplos slots manuais;
- miniatura, data e hora;
- exclusão e sobrescrita com confirmação;
- validação de versão do núcleo e identidade da ROM.

Atalhos padrão sugeridos:

| Ação | Tecla |
|---|---|
| Salvar estado rápido | F5 |
| Slot anterior | F6 |
| Próximo slot | F7 |
| Carregar estado rápido | F8 |

## Última sessão

O aplicativo registra:

```json
{
  "gameId": "sha256-da-rom",
  "startedAt": "2026-08-01T11:30:00-03:00",
  "lastPlayedAt": "2026-08-01T11:42:00-03:00",
  "savePath": "saves/<id>/save.sav",
  "saveStatePath": "savestates/<id>/automatico.state"
}
```

A página inicial apresenta duas ações distintas:

- **Continuar jogo**: abre a ROM usando o save normal;
- **Carregar último save state**: restaura o último estado instantâneo compatível.

## Velocidade

O núcleo integrado deve suportar:

- 1x, 2x, 3x e 4x;
- modo ilimitado opcional;
- avanço temporário enquanto uma tecla ou botão estiver pressionado;
- avanço alternável;
- opção de silenciar áudio durante o avanço;
- indicador visual da velocidade atual.

Atalhos padrão sugeridos:

| Ação | Tecla |
|---|---|
| Avanço temporário | Espaço |
| Alternar avanço | Tab |
| Reduzir velocidade | - |
| Aumentar velocidade | + |

## Teclado

A configuração deve permitir mapear:

- A, B, L e R;
- direcional;
- Start e Select;
- avanço rápido;
- pausa;
- salvar e carregar estado;
- tela cheia.

O aplicativo deve detectar conflitos e oferecer substituição explícita.

## Gamepads

Requisitos:

- detecção de controles conectados;
- seleção do dispositivo;
- mapeamento por botão;
- analógico como direcional;
- zona morta configurável;
- teste visual em tempo real;
- perfis por controle;
- restauração do padrão.

## Tela de jogo

A sessão integrada deve oferecer:

- framebuffer do GBA em proporção correta;
- escala inteira quando possível;
- modo tela cheia;
- pausa;
- velocidade;
- salvar/carregar estado;
- configuração de áudio;
- configuração de teclado e controle;
- controles de toque no Android.

## Dependência da integração mGBA

A biblioteca, organização e execução externa podem funcionar antes do núcleo incorporado. Entretanto, velocidade, save states, controles e renderização totalmente controlados pelo aplicativo dependem da implementação real do adaptador `libmgba` na API nativa.

## Fases de implementação

### Fase 1 — armazenamento e catálogo

- criar diretórios gerenciados;
- varrer `jogos/gba`;
- importar copiando ROMs;
- persistir metadados;
- destacar biblioteca na página inicial.

### Fase 2 — continuidade

- registrar última sessão;
- continuar último jogo;
- localizar último save normal;
- listar backups e save states.

### Fase 3 — núcleo integrado

- ligar `libmgba` à API C;
- framebuffer, áudio e entrada;
- execução e pausa;
- RTC.

### Fase 4 — recursos de emulador

- velocidade;
- save states;
- teclado configurável;
- gamepads;
- tela cheia e filtros de vídeo.

### Fase 5 — Android e distribuição

- controles de toque;
- orientação e vibração;
- pacotes Linux, Windows e Android;
- testes de migração e compatibilidade.

## Critérios de aceite da primeira entrega

- diretórios criados automaticamente;
- ROMs `.gba` colocadas em `jogos/gba` aparecem após atualização;
- catálogo preserva data de adição e último uso;
- nenhum save é apagado quando uma ROM some da pasta;
- a página inicial continua funcional sem ROMs;
- testes não dependem de ROM comercial;
- nenhuma ROM, BIOS ou save é versionado no Git.
