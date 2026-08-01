# Interface e experiência do usuário

## Direção

O produto adota uma abordagem UI/UX-first. A tarefa principal deve ser concluída com o menor número possível de decisões técnicas expostas ao usuário: abrir o aplicativo, encontrar o jogo e pressionar Continuar ou Jogar.

## Princípios

- botões principais com altura mínima de 52 px no mobile e 48 px no desktop;
- áreas de toque mínimas de 48 x 48 px;
- ações principais sempre visíveis e acompanhadas de texto;
- cartões com espaçamento interno generoso e hierarquia clara;
- adaptação responsiva sem apenas reduzir os elementos;
- mensagens de erro com causa e próxima ação;
- ações destrutivas separadas e confirmadas;
- linguagem simples e consistente;
- navegação completa por teclado e suporte futuro a gamepad.

## Navegação principal

- Biblioteca
- Recentes
- Saves
- Configurações
- Sobre

## Biblioteca

A biblioteca deve oferecer:

- estado vazio acolhedor;
- botão grande para selecionar `.gba`;
- busca por título;
- ordenação por jogo usado recentemente;
- cartões responsivos;
- ação Jogar para novos jogos;
- ação Continuar para jogos já iniciados;
- acesso à tela de detalhes tocando no cartão.

Estados obrigatórios:

- vazia com ação de importar;
- carregando;
- permissão revogada;
- arquivo ausente;
- ROM alterada;
- erro recuperável;
- busca sem resultados.

## Detalhes do jogo

A tela deve apresentar:

- identidade visual do jogo;
- título em destaque;
- botão principal Jogar agora ou Continuar jogando;
- caminho da ROM;
- data da última partida;
- estado de proteção do progresso;
- ação destrutiva no final da página.

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
- menus acessíveis sem mouse;
- cartões largos com botão Continuar ou Jogar;
- conteúdo central com largura máxima para preservar legibilidade.

## Gestão de saves

A interface deve diferenciar claramente:

- save normal do jogo (`.sav`), usado para portabilidade;
- save state, dependente da versão do núcleo.

Para cada jogo:

- data do save atual;
- tamanho e checksum abreviado;
- dispositivo da última atualização;
- lista de backups;
- importar, exportar e restaurar;
- aviso claro de incompatibilidade.

Toda substituição de save normal deve informar que um backup será criado. Conflitos nunca devem ser resolvidos silenciosamente.

## Acessibilidade

- contraste compatível com WCAG AA para textos essenciais;
- foco visível;
- escala de texto;
- rótulos semânticos;
- navegação por teclado;
- não depender apenas de cor;
- opção de reduzir animações;
- respeito às configurações de acessibilidade do sistema.

## Mensagens

Erros devem informar o que ocorreu, o que foi preservado e a próxima ação possível. Nunca mostrar apenas códigos internos.

## Responsividade

- celular retrato: biblioteca em lista e botões ocupando a largura disponível;
- celular paisagem: vídeo central e controles laterais;
- desktop: lista ou grade adaptativa e janela mínima documentada;
- componentes mudam de composição conforme a largura, sem apenas encolher.

## Critérios de aceite

- o usuário importa uma ROM sem consultar documentação;
- o usuário encontra e inicia um jogo em até dois comandos após abrir o app;
- os botões principais permanecem grandes em desktop e mobile;
- a interface não expõe termos internos como FFI ou framebuffer;
- remover um jogo não apaga a ROM e isso é informado claramente;
- erros apresentam uma ação possível para recuperação.
