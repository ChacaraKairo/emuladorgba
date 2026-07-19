import 'package:flutter/material.dart';

import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const EmulatorApp());
}

class EmulatorApp extends StatelessWidget {
  const EmulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emulador GBA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const LibraryScreen(),
    );
  }
}

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Biblioteca'),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.brandYellow,
        foregroundColor: AppColors.brandBlueDark,
        icon: const Icon(Icons.add),
        label: const Text('Importar ROM'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Seus jogos de GBA',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Importe arquivos .gba obtidos legalmente para começar.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.videogame_asset_outlined,
                            size: 64,
                            color: AppColors.brandBlue,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum jogo importado',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'A ROM permanecerá no local escolhido. O aplicativo guardará apenas metadados e saves em suas próprias pastas.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.folder_open),
                            label: const Text('Selecionar arquivo .gba'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
