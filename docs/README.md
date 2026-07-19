# Documentação do Emulador GBA

Este diretório concentra as especificações necessárias para desenvolver, testar, distribuir e manter o projeto.

## Ordem recomendada de leitura

1. [Visão do produto](product-vision.md)
2. [Requisitos](requirements.md)
3. [Arquitetura](architecture.md)
4. [Estrutura do repositório](repository-structure.md)
5. [Núcleo de emulação](emulation-core.md)
6. [Biblioteca de ROMs](rom-library.md)
7. [Formato e ciclo de vida dos saves](save-format.md)
8. [Sincronização](sync.md)
9. [Interface e experiência](ui-ux.md)
10. [Plano de testes](testing.md)
11. [Segurança e privacidade](security.md)
12. [Build, CI/CD e releases](build-release.md)
13. [Roadmap](roadmap.md)
14. [Contribuição](contributing.md)
15. [Decisões arquiteturais](adr/README.md)

## Escopo

O produto executa ROMs de Game Boy Advance armazenadas em arquivos `.gba` fornecidos legalmente pelo usuário. O projeto não distribui ROMs, BIOS, chaves, patches proprietários ou conteúdo protegido.

## Princípios

- saves normais são portáveis entre plataformas;
- save states não são o formato principal de sincronização;
- ROMs são identificadas pelo SHA-256 do conteúdo;
- operações de gravação devem ser atômicas e gerar backups;
- o frontend não deve depender diretamente da API interna do mGBA;
- toda funcionalidade crítica precisa de testes automatizados.