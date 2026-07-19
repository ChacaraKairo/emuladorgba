# Interface e experiência

## Navegação principal

- Biblioteca
- Recentes
- Saves
- Configurações
- Sobre

## Biblioteca

Exibe capa opcional, título, região/código, última execução e indicador de save. Ações: jogar, favoritar, detalhes, localizar arquivo, exportar save e remover.

Estados obrigatórios:

- vazia com ação de importar;
- carregando;
- permissão revogada;
- arquivo ausente;
- ROM alterada;
- erro recuperável.

## Tela de jogo

- área de vídeo 3:2 sem distorção;
- controles virtuais no mobile;
- barra ou menu de pausa;
- indicador temporário de velocidade;
- acesso a salvar state, carregar state, configurações e encerrar;
- confirmação apenas quando houver risco real de perda.

## Controles mobile

- direcional, A, B, L, R, Start e Select;
- posição, tamanho e opacidade configuráveis;
- suporte a toque simultâneo;
- feedback háptico opcional;
- ocultação automática com gamepad.

## Desktop

- teclado configurável;
- gamepad com hot-plug;
- tela cheia;
- atalhos para pausa, avanço rápido e captura;
- menus acessíveis sem mouse.

## Gestão de saves

Para cada jogo:

- data do save atual;
- tamanho e checksum abreviado;
- dispositivo da última atualização;
- lista de backups;
- importar, exportar e restaurar;
- aviso claro de incompatibilidade.

## Acessibilidade

- contraste adequado;
- foco visível;
- escala de texto;
- rótulos semânticos;
- navegação por teclado;
- não depender apenas de cor;
- opção de reduzir animações.

## Mensagens

Erros devem informar o que ocorreu, o que foi preservado e a próxima ação possível. Nunca mostrar apenas códigos internos.

## Responsividade

- celular retrato: biblioteca em lista e jogo com controles abaixo/sobrepostos;
- celular paisagem: vídeo central e controles laterais;
- desktop: grade adaptativa e janela mínima documentada.