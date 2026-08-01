# Build, CI/CD e releases

## Toolchain

### Camada nativa

- CMake 3.20 ou superior;
- compilador C11;
- Ninja recomendado;
- GCC e Clang no Linux;
- MSVC no Windows;
- Android NDK para Android.

### Frontend

- Flutter estável fixado por versão;
- Dart correspondente ao Flutter;
- plugins com versões fixadas.

## Build nativo local

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
ctest --test-dir build --output-on-failure
```

## Perfis

- `Debug`: símbolos, asserts e sanitizers opcionais;
- `RelWithDebInfo`: desempenho com símbolos;
- `Release`: otimizações, sem informações sensíveis;
- `Coverage`: instrumentação de cobertura.

## Matriz de CI

- Ubuntu: GCC e Clang;
- Windows: MSVC;
- Android: pelo menos uma ABI ARM64;
- Flutter: analyze, test e build por plataforma;
- documentação: verificação de links e Markdown.

## Etapas obrigatórias

1. checkout com submódulos/dependências fixadas;
2. cache seguro de dependências;
3. formatação e lint;
4. build nativo;
5. testes e sanitizers;
6. build Flutter;
7. empacotamento de artefatos de teste;
8. SBOM e auditoria de licença em release.

## Versionamento

SemVer para o aplicativo. A versão do wrapper e do backend mGBA deve aparecer nos diagnósticos. O schema de saves/metadados possui versão independente.

## Releases

- tags assinadas quando possível;
- notas com mudanças, migrações e incompatibilidades;
- checksums SHA-256 dos instaladores;
- artefatos Android, Linux e Windows;
- licença e avisos de terceiros incluídos;
- nenhum ROM, BIOS ou save nos artefatos.

## Canais

- `nightly`: instável, gerado automaticamente;
- `beta`: testes públicos com migração suportada;
- `stable`: critérios completos e compatibilidade validada.

## Rollback

Migrações de dados devem preservar cópia anterior. Releases não podem depender exclusivamente de downgrade da loja; o aplicativo deve detectar schema mais novo e evitar sobrescrita destrutiva.