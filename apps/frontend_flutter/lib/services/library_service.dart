import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_entry.dart';
import 'managed_data_directories.dart';

class LibraryService {
  static const _storageKey = 'gba_library_v2';
  static const _legacyStorageKey = 'gba_library_v1';

  Future<List<GameEntry>> load() async {
    final storedGames = await _loadStoredGames();
    return refreshManagedCatalog(existingGames: storedGames);
  }

  Future<List<GameEntry>> refreshManagedCatalog({
    List<GameEntry>? existingGames,
  }) async {
    final directories = await ManagedDataDirectories.resolve();
    final currentGames = existingGames ?? await _loadStoredGames();
    final byId = <String, GameEntry>{
      for (final game in currentGames) game.id: game,
    };

    final discovered = <GameEntry>[];
    await for (final entity in directories.games.list(followLinks: false)) {
      if (entity is! File || path.extension(entity.path).toLowerCase() != '.gba') {
        continue;
      }

      final id = await _sha256(entity);
      final previous = byId[id];
      final stat = await entity.stat();
      final game = GameEntry(
        id: id,
        title: previous?.title ?? path.basenameWithoutExtension(entity.path),
        romPath: entity.path,
        addedAt: previous?.addedAt ?? stat.changed,
        lastPlayedAt: previous?.lastPlayedAt,
      );

      await directories.ensureGameDirectories(id);
      discovered.add(game);
    }

    discovered.sort((left, right) {
      final leftDate = left.lastPlayedAt ?? left.addedAt;
      final rightDate = right.lastPlayedAt ?? right.addedAt;
      return rightDate.compareTo(leftDate);
    });

    await save(discovered);
    return discovered;
  }

  Future<List<GameEntry>> _loadStoredGames() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey) ??
        preferences.getString(_legacyStorageKey);
    if (raw == null || raw.isEmpty) {
      return <GameEntry>[];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => GameEntry.fromJson(
              Map<String, Object?>.from(item as Map<dynamic, dynamic>),
            ),
          )
          .toList(growable: true);
    } on FormatException {
      return <GameEntry>[];
    } on TypeError {
      return <GameEntry>[];
    }
  }

  Future<void> save(List<GameEntry> games) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      games.map((game) => game.toJson()).toList(growable: false),
    );
    await preferences.setString(_storageKey, encoded);
  }

  Future<String> _sha256(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }
}
