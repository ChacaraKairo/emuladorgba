# Sistema visual

## Direção

A interface deve lembrar a energia visual de jogos de captura e batalha de criaturas, usando cores vivas, cartões arredondados, contornos fortes e hierarquia clara. O projeto não deve copiar logotipos, ilustrações, fontes proprietárias, ícones ou telas oficiais.

## Paleta principal

| Token | Cor | Uso |
|---|---|---|
| `brandBlue` | `#2F6FDB` | navegação, ações primárias e foco |
| `brandBlueDark` | `#173B73` | textos fortes, cabeçalhos e superfícies escuras |
| `brandYellow` | `#FFD84D` | destaques, seleção e chamadas secundárias |
| `brandRed` | `#E5484D` | ações destrutivas, erro e indicador de gravação |
| `brandGreen` | `#43A047` | sucesso, save sincronizado e estado disponível |
| `surfaceLight` | `#F7F9FC` | fundo claro |
| `cardLight` | `#FFFFFF` | cartões no tema claro |
| `surfaceDark` | `#101828` | fundo escuro |
| `cardDark` | `#1D2939` | cartões no tema escuro |

## Regras

- azul é a cor primária do produto;
- amarelo é usado com moderação para seleção e energia visual;
- vermelho não deve ser usado como cor primária de navegação;
- estados nunca podem depender somente de cor;
- textos devem manter contraste mínimo de 4,5:1;
- cantos de cartões: 16 px;
- botões principais: altura mínima de 48 px;
- áreas de toque no Android: mínimo de 48 x 48 px;
- a tela do jogo deve manter o conteúdo da ROM sem filtros cromáticos obrigatórios.

## Componentes

### Cartão de jogo

- capa ou placeholder;
- título;
- código do jogo;
- último save;
- status de integridade;
- ação principal `Jogar`.

### Indicadores

- verde: save íntegro e sincronizado;
- amarelo: mudança local aguardando sincronização;
- vermelho: conflito ou falha;
- azul: informação neutra.

### Controles virtuais

Os controles devem ser semitransparentes, configuráveis e não utilizar imagens oficiais. Botões A e B podem usar as cores amarela e vermelha, mantendo rótulos textuais visíveis.