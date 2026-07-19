# Contrato da API nativa

## Objetivo

Fornecer uma ABI C pequena, versionada e segura para Flutter FFI, CLIs e testes. A API pública não expõe tipos do mGBA.

## Regras gerais

- funções públicas usam `emugba_`;
- cada operação retorna `emugba_result` ou valor documentado;
- ponteiros de saída são validados;
- strings públicas são UTF-8;
- buffers informam endereço, tamanho e ownership;
- erros não deixam objetos parcialmente válidos;
- funções não são thread-safe salvo indicação explícita;
- cada sessão é usada por uma única thread de emulação.

## Objetos opacos planejados

```c
typedef struct emugba_session emugba_session;
```

## Ciclo de vida planejado

```c
emugba_result emugba_session_create(
    const emugba_session_config* config,
    emugba_session** out_session);

emugba_result emugba_session_load_rom_file(
    emugba_session* session,
    const char* rom_path);

emugba_result emugba_session_run_frame(
    emugba_session* session);

emugba_result emugba_session_set_buttons(
    emugba_session* session,
    uint32_t button_mask);

emugba_result emugba_session_flush_save(
    emugba_session* session);

void emugba_session_destroy(emugba_session* session);
```

## Callbacks planejados

- frame de vídeo disponível;
- amostras de áudio disponíveis;
- save modificado;
- log estruturado;
- erro assíncrono fatal.

Callbacks não podem bloquear a thread de emulação por períodos longos.

## Compatibilidade

`emugba_get_api_version()` retorna a versão da API do wrapper. Mudanças incompatíveis incrementam `major`. Campos adicionais em structs devem usar `struct_size` para compatibilidade progressiva.

## Erros

Categorias mínimas:

- argumento inválido;
- estado inválido;
- arquivo não encontrado;
- arquivo não suportado;
- ROM inválida;
- falha de I/O;
- backend indisponível;
- memória insuficiente;
- save incompatível;
- operação não implementada.

## FFI

A camada Dart deve possuir um serviço que converte códigos nativos em resultados de domínio. Widgets não podem chamar ponteiros FFI diretamente. Recursos nativos devem ser liberados por fluxo explícito, com finalizer apenas como proteção adicional.