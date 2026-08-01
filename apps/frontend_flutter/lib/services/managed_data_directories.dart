import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'settings_service.dart';

class ManagedDataDirectories {
  const ManagedDataDirectories._({required this.root});

  final Directory root;

  Directory get games => Directory(path.join(root.path, 'jogos', 'gba'));
  Directory get saves => Directory(path.join(root.path, 'saves'));
  Directory get saveStates => Directory(path.join(root.path, 'savestates'));
  Directory get covers => Directory(path.join(root.path, 'capas'));
  Directory get metadata => Directory(path.join(root.path, 'metadados'));
  Directory get configuration => Directory(path.join(root.path, 'configuracoes'));
  Directory get logs => Directory(path.join(root.path, 'logs'));

  static Future<ManagedDataDirectories> resolve({
    SettingsService? settingsService,
  }) async {
    final settings = await (settingsService ?? SettingsService()).load();
    final configured = settings.dataDirectory.trim();

    final Directory root;
    if (configured.isNotEmpty) {
      root = Directory(configured);
    } else {
      final documents = await getApplicationDocumentsDirectory();
      root = Directory(path.join(documents.path, 'EmuladorGBA'));
    }

    final directories = ManagedDataDirectories._(root: root);
    await directories.ensureCreated();
    return directories;
  }

  Future<void> ensureCreated() async {
    for (final directory in <Directory>[
      root,
      games,
      saves,
      saveStates,
      covers,
      metadata,
      configuration,
      logs,
    ]) {
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    }
  }

  Directory saveDirectoryFor(String gameId) =>
      Directory(path.join(saves.path, gameId));

  Directory saveBackupDirectoryFor(String gameId) =>
      Directory(path.join(saveDirectoryFor(gameId).path, 'backups'));

  Directory saveStateDirectoryFor(String gameId) =>
      Directory(path.join(saveStates.path, gameId));

  Directory saveStateSlotsDirectoryFor(String gameId) =>
      Directory(path.join(saveStateDirectoryFor(gameId).path, 'slots'));

  Future<void> ensureGameDirectories(String gameId) async {
    for (final directory in <Directory>[
      saveDirectoryFor(gameId),
      saveBackupDirectoryFor(gameId),
      saveStateDirectoryFor(gameId),
      saveStateSlotsDirectoryFor(gameId),
    ]) {
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    }
  }
}
