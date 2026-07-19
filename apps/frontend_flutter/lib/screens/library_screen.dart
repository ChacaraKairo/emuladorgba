import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../models/game_entry.dart';
import '../services/emulator_launcher.dart';
import '../services/library_service.dart';
import '../theme/app_colors.dart';
import 'game_details_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryService _libraryService = LibraryService();
  final EmulatorLauncher _launcher = EmulatorLauncher();
  final TextEditingController _searchController = TextEditingController();

  List<GameEntry> _games = <GameEntry>[];
  bool _loading = true;
  bool _importing = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLibrary() async {
    final games = await _libraryService.load();
    _sortGames(games);
    if (!mounted) return;
    setState(() {
      _games = games;
      _loading = false;
    });
  }

  void _sortGames(List<GameEntry> games) {
    games.sort((left, right) {
      final leftDate = left.lastPlayedAt ?? left.addedAt;
      final rightDate = right.lastPlayedAt ?? right.addedAt;
      return rightDate.compareTo(leftDate);
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
      );
      final romPath = result?.files.single.path;
      if (romPath == null) return;
      if (!await File(romPath).exists()) {
        _showMessage('O arquivo selecionado não está disponível.');
        return;
      }
      if (path.extension(romPath).toLowerCase() != '.gba') {
        _showMessage('Selecione um arquivo com extensão .gba.');
        return;
      }
      if (_games.any((game) => game.romPath == romPath)) {
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
      _sortGames(games);
      setState(() => _games = games);
      await _libraryService.save(_games);
    } on EmulatorLaunchException catch (error) {
      _showMessage(error.message);
    }
  }

  Future<bool> _remove(GameEntry game) async {
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
            style: FilledButton.styleFrom(backgroundColor: AppColors.brandRed),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;
    setState(() {
      _games = _games.where((item) => item.id != game.id).toList();
    });
    await _libraryService.save(_games);
    return true;
  }

  void _openDetails(GameEntry game) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameDetailsScreen(
          game: game,
          onPlay: () => _play(game),
          onRemove: () async {
            await _remove(game);
          },
        ),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final visibleGames = _games
        .where((game) => game.title.toLowerCase().contains(_query.toLowerCase()))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Biblioteca'),
        actions: [
          IconButton(
            tooltip: 'Atualizar biblioteca',
            onPressed: _loadLibrary,
            icon: const Icon(Icons.refresh_rounded),
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
            : const Icon(Icons.add_rounded),
        label: Text(_importing ? 'Importando...' : 'Importar ROM'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Seus jogos de GBA',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha um jogo e continue sua aventura.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (_games.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        hintText: 'Buscar na biblioteca',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _games.isEmpty
                            ? _EmptyLibrary(onImport: _importRom)
                            : visibleGames.isEmpty
                                ? const _EmptySearch()
                                : ListView.separated(
                                    itemCount: visibleGames.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 14),
                                    itemBuilder: (context, index) {
                                      final game = visibleGames[index];
                                      return _GameCard(
                                        game: game,
                                        onPlay: () => _play(game),
                                        onDetails: () => _openDetails(game),
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),
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
    required this.onDetails,
  });

  final GameEntry game;
  final VoidCallback onPlay;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDetails,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;
              final information = Row(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.brandYellow, width: 3),
                    ),
                    child: const Icon(
                      Icons.catching_pokemon,
                      color: AppColors.brandBlue,
                      size: 40,
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
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          game.lastPlayedAt == null
                              ? 'Novo na biblioteca'
                              : 'Pronto para continuar',
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final playButton = SizedBox(
                height: 54,
                width: compact ? double.infinity : 190,
                child: FilledButton.icon(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: Text(
                    game.lastPlayedAt == null ? 'Jogar' : 'Continuar',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              );

              if (compact) {
                return Column(
                  children: [
                    information,
                    const SizedBox(height: 16),
                    playButton,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: information),
                  const SizedBox(width: 18),
                  playButton,
                ],
              );
            },
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
                size: 72,
                color: AppColors.brandBlue,
              ),
              const SizedBox(height: 18),
              Text(
                'Sua biblioteca está pronta',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Adicione uma ROM .gba obtida legalmente para começar.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 56,
                width: 280,
                child: FilledButton.icon(
                  onPressed: onImport,
                  icon: const Icon(Icons.folder_open_rounded),
                  label: const Text(
                    'Selecionar arquivo .gba',
                    style: TextStyle(fontWeight: FontWeight.w800),
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

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 58),
          SizedBox(height: 12),
          Text('Nenhum jogo encontrado'),
        ],
      ),
    );
  }
}
