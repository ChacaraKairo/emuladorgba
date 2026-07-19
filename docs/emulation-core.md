# Núcleo de emulação

## Decisão

O backend inicial será o mGBA, encapsulado por uma API C própria. O frontend nunca deve incluir cabeçalhos internos do mGBA.

## Responsabilidades da API

- criar e destruir uma instância;
- carregar ROM a partir de caminho ou buffer somente-leitura;
- carregar BIOS opcional;
- definir caminho ou callbacks de save;
- executar um frame;
- pausar, reiniciar e encerrar;
- fornecer framebuffer RGBA ou formato documentado;
- fornecer amostras de áudio PCM;
- receber estado dos botões;
- consultar FPS, estado e erros;
- importar/exportar save normal;
- criar/carregar save state com versão explícita.

## Modelo de sessão

Estados válidos:

```text
CREATED -> ROM_LOADED -> RUNNING <-> PAUSED -> STOPPED -> DESTROYED
```

Chamadas incompatíveis com o estado atual retornam erro e não alteram a sessão.

## Contrato de vídeo

- resolução nativa: 240x160;
- proporção: 3:2;
- o núcleo entrega frames sem aplicar escala da interface;
- filtros e shaders pertencem ao frontend/renderizador;
- o buffer permanece válido apenas pelo período documentado.

## Contrato de áudio

- PCM estéreo intercalado;
- taxa configurável ou normalizada pelo wrapper;
- fila limitada para evitar latência crescente;
- o frontend informa underrun/overflow para telemetria local.

## Entrada

Bitmask estável para A, B, L, R, Start, Select e direcional. O frontend resolve teclado, gamepad e toque para esse bitmask.

## RTC

- usar relógio do sistema por padrão;
- permitir offset apenas para testes;
- persistir os dados auxiliares exigidos pelo backend;
- nunca alterar silenciosamente o relógio do jogo.

## Integração do mGBA

A versão deve ser fixada por tag ou commit. Atualizações exigem:

1. revisão da licença e changelog;
2. execução da suíte de compatibilidade;
3. teste de saves anteriores;
4. teste de save states, que podem ser invalidados;
5. registro em ADR.

## Encerramento seguro

Antes de destruir a sessão:

1. pausar execução;
2. solicitar flush do save;
3. copiar o save para buffer controlado;
4. gravar atomicamente pelo `save_manager`;
5. liberar áudio, vídeo e núcleo.