# Estratégia de testes

## Objetivos

- prevenir corrupção de saves;
- detectar regressões do núcleo;
- manter a API C estável;
- validar Android, Linux e Windows;
- medir desempenho e latência.

## Pirâmide

### Unitários

- SHA-256 e leitura de cabeçalho;
- validação de extensão e caminhos;
- máquina de estados da sessão;
- criação de nomes e diretórios;
- gravação atômica;
- rotação de backups;
- comparação de revisões e conflitos;
- serialização de metadados.

### Integração

- wrapper com backend falso;
- importação de ROM sintética;
- ciclo abrir, executar, salvar e fechar;
- falha simulada durante escrita;
- permissões revogadas;
- troca de diretório;
- comunicação Flutter/FFI.

### Compatibilidade

Usar homebrew, ROMs de teste permitidas e ROMs fornecidas localmente pelo mantenedor, nunca versionadas. A matriz deve cobrir CPU, vídeo, áudio, timers, DMA, RTC, EEPROM, SRAM e Flash.

### End-to-end

- importar e abrir jogo;
- configurar controle;
- criar save dentro do jogo;
- reiniciar aplicativo;
- exportar no desktop e importar no Android;
- restaurar backup;
- atualizar aplicativo sem perder dados.

## Testes específicos de Pokémon

- Flash 128 KiB;
- RTC e eventos temporais;
- save após Elite Four e outras transições longas;
- alternância entre versões/regiões sem associação automática;
- ROM hacks com tamanhos maiores, quando fornecidos legalmente;
- detecção de save incompatível.

## Testes de falha

Injetar falhas em `open`, `read`, `write`, `flush`, `rename` e falta de espaço. O save anterior deve continuar recuperável.

## Desempenho

Registrar:

- tempo de inicialização;
- FPS e frame time percentis 50/95/99;
- underruns de áudio;
- uso de CPU e memória;
- consumo de bateria em sessão padronizada;
- latência entre input e frame.

## Sanitizers e análise

- AddressSanitizer e UndefinedBehaviorSanitizer em Linux;
- análise estática de C/C++;
- `dart analyze`;
- formatação obrigatória;
- auditoria de dependências.

## Critério de merge

Todo PR deve passar build, testes unitários e análise estática. Mudanças em saves exigem teste de migração e recuperação. Mudanças no núcleo exigem matriz de compatibilidade.