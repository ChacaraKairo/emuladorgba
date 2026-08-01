# Armazenamento local

## Diretório lógico

```text
EmuladorGBA/
├── library/
│   └── library.json ou banco local
├── games/
│   └── <rom-sha256>/
│       ├── metadata.json
│       ├── save/
│       │   ├── game.sav
│       │   ├── rtc.dat
│       │   └── manifest.json
│       ├── backups/
│       ├── states/
│       ├── screenshots/
│       └── settings.json
├── bios/
├── cache/
├── logs/
└── config/
```

Os caminhos físicos são definidos por plataforma. A interface trabalha com um serviço de armazenamento e não concatena caminhos diretamente.

## Regras

- ROM original permanece somente-leitura;
- saves não ficam ao lado da ROM por padrão;
- cada hash possui espaço isolado;
- temporários usam o mesmo volume do destino para permitir rename atômico;
- cache pode ser apagado sem perda de dados;
- configurações globais e por jogo são separadas;
- schemas possuem versão.

## Gravação atômica

1. escrever `arquivo.tmp`;
2. finalizar e solicitar flush;
3. validar tamanho e checksum;
4. mover arquivo atual para backup;
5. renomear temporário para destino;
6. atualizar manifesto por operação atômica equivalente;
7. remover temporários obsoletos na próxima inicialização.

## Backups

Política inicial:

- antes de importar;
- antes de sincronizar/substituir;
- ao detectar migração;
- no encerramento, quando o conteúdo mudou;
- retenção configurável, padrão de 10 versões;
- nunca excluir o único save válido.

## Banco local

O MVP pode começar com JSON protegido por escrita atômica. Quando consultas, migrações ou volume justificarem, usar SQLite. O conteúdo binário de saves permanece em arquivos, não em BLOBs.

## Migrações

- ler versão antes de modificar;
- criar snapshot do diretório afetado;
- aplicar migração idempotente;
- validar resultado;
- registrar conclusão;
- restaurar snapshot em falha.

## Exclusão

Remover um jogo da biblioteca não apaga ROM ou saves por padrão. Exclusão definitiva exige seleção explícita dos grupos de dados e confirmação clara.