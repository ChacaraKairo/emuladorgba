import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_entry.dart';

class LibraryService {
  static const _storageKey = 'gba_library_v1';

  Future<List<GameEntry>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
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
}
