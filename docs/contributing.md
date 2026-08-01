# Guia de contribuição

## Preparação

1. Leia `docs/README.md` e os ADRs.
2. Crie uma branch a partir da base correta.
3. Mantenha o escopo pequeno e testável.
4. Nunca adicione ROMs, BIOS, saves ou material protegido.

## Fluxo

```bash
git checkout -b feature/nome-curto
cmake -S . -B build -G Ninja
cmake --build build
ctest --test-dir build --output-on-failure
```

Para Flutter, execute formatação, `flutter analyze` e testes antes do PR.

## Pull requests

O PR deve descrever:

- problema e objetivo;
- solução adotada;
- impacto em saves e compatibilidade;
- testes executados;
- plataformas validadas;
- screenshots quando houver interface;
- atualização de documentação e ADR quando necessário.

## Código nativo

- API pública usa prefixo `emugba_`;
- evitar estado global mutável;
- validar ponteiros, tamanhos e estados;
- nenhuma alocação baseada em tamanho não validado;
- ownership de buffers deve estar documentado;
- warnings são erros.

## Flutter

- separar apresentação, domínio e infraestrutura;
- não chamar FFI diretamente a partir de widgets;
- estados de erro devem ser representados explicitamente;
- textos visíveis devem ser preparados para localização;
- novos fluxos precisam de testes de widget.

## Saves

Mudanças em formato, diretório ou migração exigem:

- versão de schema;
- backup antes da migração;
- teste de ida e recuperação;
- documentação de incompatibilidades;
- revisão adicional.

## Dependências

Toda dependência precisa de justificativa, licença compatível, versão fixada e avaliação de manutenção. Evite bibliotecas para funcionalidades pequenas.

## Commits

Use mensagens curtas e imperativas, por exemplo:

- `feat: adicionar importação de save`
- `fix: preservar backup após falha de rename`
- `docs: detalhar contrato de áudio`

## Revisão

Não aprovar código que dependa de ROM comercial no CI, exponha dados privados, ignore falhas de escrita ou acople o frontend diretamente ao mGBA.