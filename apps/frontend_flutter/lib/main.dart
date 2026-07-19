import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'models/game_entry.dart';
import 'services/emulator_launcher.dart';
import 'services/library_service.dart';
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

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryService _libraryService = LibraryService();
  final EmulatorLauncher _launcher = EmulatorLauncher();

  List<GameEntry> _games = <GameEntry>[];
  bool _loading = true;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    final games = await _libraryService.load();
    games.sort((left, right) {
      final leftDate = left.lastPlayedAt ?? left.addedAt;
      final rightDate = right.lastPlayedAt ?? right.addedAt;
      return rightDate.compareTo(leftDate);
    });
    if (!mounted) return;
    setState(() {
      _games = games;
      _loading = false;
    });
  }

  Future<void> _importRom() async {
    if (_importing) return;
    setState(() => _importing = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Selecione uma ROM de Game Boy Advance',
        type: FileType.custom,
        allowedExtensions: const <String>['gba'],
        allowMultiple: false,
      );
      final romPath = result?.files.single.path;
      if (romPath == null) return;

      final file = File(romPath);
      if (!await file.exists()) {
        _showMessage('O arquivo selecionado não está disponível.');
        return;
      }
      if (path.extension(romPath).toLowerCase() != '.gba') {
        _showMessage('Selecione um arquivo com extensão .gba.');
        return;
      }

      final duplicate = _games.any((game) => game.romPath == romPath);
      if (duplicate) {
        _showMessage('Este jogo já está na biblioteca.');
        return;
      }

      final now = DateTime.now();
      final game = GameEntry(
        id: '${now.microsecondsSinceEpoch}-${path.basename(romPath)}',
        title: path.basenameWithoutExtension(romPath),
        romPath: romPath,
        addedAt: now,
      );
      setState(() => _games = <GameEntry>[game, ..._games]);
      await _libraryService.save(_games);
      _showMessage('ROM adicionada à biblioteca.');
    } catch (error) {
      _showMessage('Não foi possível importar a ROM: $error');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _play(GameEntry game) async {
    try {
      await _launcher.launch(game.romPath);
      final updated = game.copyWith(lastPlayedAt: DateTime.now());
      final games = _games
          .map((item) => item.id == game.id ? updated : item)
          .toList(growable: true);
      games.sort((left, right) {
        final leftDate = left.lastPlayedAt ?? left.addedAt;
        final rightDate = right.lastPlayedAt ?? right.addedAt;
        return rightDate.compareTo(leftDate);
      });
      setState(() => _games = games);
      await _libraryService.save(_games);
    } on EmulatorLaunchException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<void> _remove(GameEntry game) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover da biblioteca?'),
        content: Text(
          '“${game.title}” será removido somente da biblioteca. A ROM não será apagada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _games = _games.where((item) => item.id != game.id).toList();
    });
    await _libraryService.save(_games);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Biblioteca'),
        actions: [
          IconButton(
            tooltip: 'Atualizar biblioteca',
            onPressed: _loadLibrary,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importing ? null : _importRom,
        backgroundColor: AppColors.brandYellow,
        foregroundColor: AppColors.brandBlueDark,
        icon: _importing
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
        label: Text(_importing ? 'Importando...' : 'Importar ROM'),
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
                'Importe arquivos .gba obtidos legalmente e pressione Jogar.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _games.isEmpty
                        ? _EmptyLibrary(onImport: _importRom)
                        : ListView.separated(
                            itemCount: _games.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final game = _games[index];
                              return _GameCard(
                                game: game,
                                onPlay: () => _play(game),
                                onRemove: () => _remove(game),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onImport});

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                'A ROM permanece no local escolhido. O aplicativo não distribui nem baixa jogos.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.folder_open),
                label: const Text('Selecionar arquivo .gba'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.onPlay,
    required this.onRemove,
  });

  final GameEntry game;
  final VoidCallback onPlay;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.brandBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.catching_pokemon,
                color: AppColors.brandBlue,
                size: 34,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.romPath,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (game.lastPlayedAt != null) ...[
                    const SizedBox(height: 4),
                    const Text('Jogado recentemente'),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: onPlay,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Jogar'),
            ),
            IconButton(
              tooltip: 'Remover da biblioteca',
              onPressed: onRemove,
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }
}
