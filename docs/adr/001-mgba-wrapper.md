# ADR-001 — mGBA atrás de API C própria

Status: aceita

Data: 2026-07-19

## Contexto

O projeto precisa de um núcleo de GBA preciso, eficiente e com suporte a RTC, tipos de save utilizados por Pokémon, múltiplas plataformas e integração programática. Acoplar Flutter diretamente às estruturas internas de um emulador dificultaria atualizações e testes.

## Decisão

Usar mGBA como backend inicial e criar uma API C estável pertencente ao projeto. Somente o adaptador interno conhece a API do mGBA. Frontend, gerenciador de saves e biblioteca dependem de contratos do projeto.

## Alternativas consideradas

- Libretro: boa padronização, mas adiciona abstração e limita acesso a recursos específicos.
- SkyEmu: licença favorável e boa portabilidade, porém menos estruturado como biblioteca de integração.
- gpSP: excelente desempenho em hardware fraco, mas menor prioridade de precisão.
- desenvolver núcleo próprio: custo e risco incompatíveis com o MVP.

## Consequências positivas

- precisão e suporte a recursos importantes de Pokémon;
- possibilidade de trocar ou atualizar backend;
- testes com backend falso;
- API FFI mais simples;
- frontend sem dependência de detalhes internos.

## Consequências negativas

- manutenção de uma camada adaptadora;
- obrigação de acompanhar licença e atualizações do mGBA;
- alguns recursos podem exigir extensão do wrapper;
- save states podem mudar entre versões do backend.

## Critérios de revisão

Reavaliar quando o mGBA não atender uma plataforma-alvo, apresentar problema de licença, desempenho insuficiente ou impedir recurso essencial. Uma troca exige prova de compatibilidade de saves e matriz de testes.