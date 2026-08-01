# Biblioteca de ROMs

## Importação

1. O usuário escolhe um arquivo pelo seletor da plataforma.
2. O aplicativo verifica a extensão `.gba`.
3. O leitor valida o tamanho mínimo e o cabeçalho.
4. É calculado o SHA-256 do conteúdo.
5. Metadados são extraídos.
6. A biblioteca procura uma entrada com o mesmo hash.
7. A entrada é criada ou atualizada sem copiar o arquivo, salvo quando o usuário escolher biblioteca gerenciada.

## Modos de armazenamento

### Referenciado

A biblioteca guarda a URI/caminho concedido pelo sistema. É o padrão no desktop.

### Gerenciado

O aplicativo copia a ROM para uma pasta privada. É útil no Android quando permissões persistentes não estiverem disponíveis.

## Modelo de dados

```json
{
  "schemaVersion": 1,
  "id": "sha256 completo",
  "title": "nome visível",
  "internalTitle": "título do cabeçalho",
  "gameCode": "BPEE",
  "makerCode": "01",
  "romUri": "URI ou caminho",
  "storageMode": "referenced",
  "fileSize": 16777216,
  "headerChecksumValid": true,
  "favorite": false,
  "lastPlayedAt": null,
  "playTimeSeconds": 0
}
```

## Identidade

O identificador canônico é o SHA-256. Nome, caminho e título podem mudar sem criar outro jogo.

## Alteração externa

Antes de iniciar, o aplicativo verifica tamanho e data de modificação. Quando houver mudança, recalcula o hash e pergunta se deve registrar como nova ROM.

## Duplicatas

Arquivos com o mesmo hash compartilham a mesma identidade e save. Arquivos com hashes diferentes nunca compartilham automaticamente saves, mesmo quando possuem o mesmo título.

## Patches

Patches IPS/UPS/BPS poderão ser suportados posteriormente. A identidade efetiva deve incluir a ROM-base e o patch aplicado. O projeto não armazenará ou distribuirá ROM derivada sem autorização.

## Erros esperados

- arquivo removido ou permissão revogada;
- extensão incorreta;
- cabeçalho truncado;
- falha de leitura;
- ROM alterada externamente;
- armazenamento insuficiente no modo gerenciado.