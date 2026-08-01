# Documentação do Emulador GBA

Este diretório concentra as especificações necessárias para desenvolver, testar, distribuir e manter o projeto.

## Ordem recomendada de leitura

1. [Visão do produto](product-vision.md)
2. [Requisitos](requirements.md)
3. [Catálogo, armazenamento e experiência do emulador](catalogo-emulador.md)
4. [Arquitetura](architecture.md)
5. [Estrutura do repositório](repository-structure.md)
6. [Plataformas](platforms.md)
7. [Contrato da API nativa](api-contract.md)
8. [Núcleo de emulação](emulation-core.md)
9. [Biblioteca de ROMs](rom-library.md)
10. [Armazenamento local](data-storage.md)
11. [Formato e ciclo de vida dos saves](save-format.md)
12. [Sincronização](sync.md)
13. [Interface e experiência](ui-ux.md)
14. [Sistema visual](design-system.md)
15. [Plano de testes](testing.md)
16. [Segurança e privacidade](security.md)
17. [Build, CI/CD e releases](build-release.md)
18. [Roadmap](roadmap.md)
19. [Contribuição](contributing.md)
20. [Decisões arquiteturais](adr/README.md)

## Escopo

O produto executa ROMs de Game Boy Advance armazenadas em arquivos `.gba` fornecidos legalmente pelo usuário. O projeto não distribui ROMs, BIOS, chaves, patches proprietários ou conteúdo protegido.

## Princípios

- saves normais são portáveis entre plataformas;
- save states não são o formato principal de sincronização;
- ROMs são identificadas pelo SHA-256 do conteúdo;
- operações de gravação devem ser atômicas e gerar backups;
- o frontend não deve depender diretamente da API interna do mGBA;
- toda funcionalidade crítica precisa de testes automatizados.

## Manutenção

Toda alteração que modifique comportamento público, armazenamento, compatibilidade, dependências, segurança ou fluxo do usuário deve atualizar a documentação correspondente. Decisões difíceis de reverter devem receber um ADR.
