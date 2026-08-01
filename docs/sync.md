# Sincronização de saves

## Objetivo

Permitir que o mesmo save normal seja usado no Android, Linux e Windows sem exigir que a ROM seja enviada.

## Unidade sincronizável

- `game.sav` ou formato normalizado equivalente;
- `metadata.json`;
- dados de RTC quando necessários;
- opcionalmente configurações por jogo.

Save states ficam desativados por padrão na sincronização por serem dependentes do núcleo e da versão.

## Estratégias

### MVP: exportação/importação

O usuário exporta `.sav` ou um pacote `.egsave`. A importação sempre cria backup.

### Pasta sincronizada

O usuário escolhe uma pasta administrada por serviço externo. O aplicativo observa alterações e resolve conflitos.

### Nuvem própria futura

API autenticada, armazenamento de objetos e metadados versionados. ROMs não são enviadas.

## Manifesto

```json
{
  "schemaVersion": 1,
  "romSha256": "...",
  "saveSha256": "...",
  "saveSize": 131072,
  "revision": 12,
  "updatedAt": "2026-07-19T02:00:00Z",
  "deviceId": "uuid",
  "core": "mgba",
  "coreVersion": "fixada"
}
```

## Detecção de conflito

Existe conflito quando duas revisões descendem da mesma revisão-base e possuem checksums diferentes. Data de modificação sozinha não decide qual versão vencerá.

Opções apresentadas:

- manter local;
- usar recebida;
- guardar as duas como backups;
- cancelar.

## Fluxo de importação

1. validar manifesto e limites de tamanho;
2. confirmar correspondência do hash da ROM;
3. calcular checksum do conteúdo recebido;
4. pausar ou impedir sessão ativa;
5. criar backup local;
6. gravar temporário;
7. validar leitura;
8. substituir atomicamente;
9. atualizar revisão e histórico.

## Segurança

- rejeitar caminhos dentro de pacotes;
- limitar tamanhos antes de descompactar;
- não executar conteúdo importado;
- não aceitar ROM dentro do pacote;
- criptografia em trânsito e repouso para nuvem própria;
- opção de criptografia ponta a ponta em etapa futura.