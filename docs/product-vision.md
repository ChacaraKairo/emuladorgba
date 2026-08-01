# Visão do produto

## Problema

Jogadores mantêm ROMs e saves de GBA em dispositivos diferentes, com estruturas incompatíveis, risco de sobrescrita e dificuldade para continuar a mesma partida no celular e no computador.

## Proposta

Criar um emulador multiplataforma, inicialmente para Android, Linux e Windows, que organize arquivos `.gba`, execute jogos com um núcleo confiável e permita transportar saves normais com segurança.

## Público-alvo

- usuários que possuem backups legais de jogos GBA;
- jogadores de Pokémon e ROM hacks legais;
- usuários que alternam entre celular e computador;
- desenvolvedores e testadores de homebrew para GBA.

## Diferenciais

- biblioteca baseada em hash, não no nome do arquivo;
- backups automáticos antes de importar ou substituir saves;
- suporte correto a RTC;
- importação e exportação simples de `.sav`;
- interface consistente em mobile e desktop;
- arquitetura preparada para recursos específicos de Pokémon sem acoplar o núcleo ao frontend.

## MVP

O MVP estará concluído quando o usuário puder importar uma ROM `.gba`, iniciar o jogo, usar controles, ouvir áudio, salvar dentro do jogo, fechar o aplicativo e continuar a partida em outro dispositivo usando o mesmo `.sav`.

## Fora do escopo inicial

- catálogo ou download de ROMs;
- multiplayer pela internet;
- emulação de Nintendo DS;
- edição de Pokémon ou saves;
- nuvem própria obrigatória;
- compatibilidade garantida de save states entre versões.

## Métricas

- taxa de ROMs de teste que iniciam corretamente;
- ausência de corrupção em testes de interrupção de gravação;
- latência de entrada e estabilidade de áudio;
- consumo de CPU e bateria no Android;
- sucesso de importação cruzada de saves;
- número de falhas por sessão.