# Segurança e privacidade

## Modelo de ameaça

O aplicativo processa arquivos não confiáveis escolhidos pelo usuário. ROMs, saves, patches, capas e pacotes importados podem estar malformados.

## Controles obrigatórios

- validar limites antes de alocar memória;
- tratar todos os tamanhos como potencialmente maliciosos;
- evitar aritmética inteira sem checagem;
- nunca executar comandos construídos com caminhos do usuário;
- impedir traversal (`../`) e links simbólicos inesperados em pacotes;
- gravar somente em diretórios concedidos ou privados;
- manter núcleo e parsers atualizados após revisão;
- usar permissões mínimas no Android.

## ROMs

- leitura somente-leitura por padrão;
- nenhuma ROM é enviada a servidores;
- nenhum conteúdo da ROM aparece integralmente em logs;
- hash pode ser usado localmente para identidade;
- cópia para biblioteca gerenciada requer consentimento explícito.

## Saves

Saves são dados do usuário e podem conter nomes escolhidos por ele. Devem ser tratados como privados.

- backups locais por padrão;
- exportação somente por ação explícita;
- nuvem futura com TLS e criptografia em repouso;
- exclusão deve informar se backups também serão removidos;
- logs registram somente identificadores abreviados e códigos de erro.

## Dependências

- versões fixadas;
- SBOM em releases;
- auditoria de licenças;
- alertas de vulnerabilidade;
- atualização do mGBA somente após testes.

## Relato de vulnerabilidade

Criar `SECURITY.md` com canal privado antes do primeiro release público. Issues públicas não devem incluir exploits, ROMs ou saves privados.

## Privacidade

O MVP não exige conta, telemetria ou conexão. Qualquer telemetria futura deve ser opcional, agregada, documentada e desativável.

## Segredos

Nenhuma chave deve ficar no repositório. CI usa secrets do provedor com escopo mínimo. Builds locais devem funcionar sem credenciais quando recursos de nuvem estiverem desativados.