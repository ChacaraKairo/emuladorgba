import 'dart:io';

import 'package:path/path.dart' as path;

class SaveSnapshot {
  const SaveSnapshot({
    required this.path,
    required this.modifiedAt,
    required this.size,
  });

  final String path;
  final DateTime modifiedAt;
  final int size;
}

class SaveManagerService {
  String externalSavePath(String romPath) =>
      path.setExtension(romPath, '.sav');

  Directory gameDirectory(String root, String gameId) =>
      Directory(path.join(root, 'games', _safeId(gameId)));

  Future<File?> detectExternalSave(String romPath) async {
    final candidate = File(externalSavePath(romPath));
    return await candidate.exists() ? candidate : null;
  }

  Future<File?> canonicalSave(String root, String gameId) async {
    final file = File(path.join(gameDirectory(root, gameId).path, 'save.sav'));
    return await file.exists() ? file : null;
  }

  Future<File?> backupBeforePlay({
    required String root,
    required String gameId,
    required String romPath,
  }) async {
    final external = await detectExternalSave(romPath);
    if (external == null) return null;
    return _backup(root, gameId, external, 'before');
  }

  Future<File?> captureAfterPlay({
    required String root,
    required String gameId,
    required String romPath,
  }) async {
    final external = await detectExternalSave(romPath);
    if (external == null) return null;
    final directory = gameDirectory(root, gameId);
    await directory.create(recursive: true);
    final canonical = File(path.join(directory.path, 'save.sav'));
    await external.copy('${canonical.path}.tmp');
    final temporary = File('${canonical.path}.tmp');
    if (await canonical.exists()) await canonical.delete();
    await temporary.rename(canonical.path);
    return _backup(root, gameId, canonical, 'after');
  }

  Future<void> restoreCanonicalBeforePlay({
    required String root,
    required String gameId,
    required String romPath,
  }) async {
    final canonical = await canonicalSave(root, gameId);
    if (canonical == null) return;
    await canonical.copy(externalSavePath(romPath));
  }

  Future<List<SaveSnapshot>> listBackups(String root, String gameId) async {
    final backups = Directory(
      path.join(gameDirectory(root, gameId).path, 'backups'),
    );
    if (!await backups.exists()) return const <SaveSnapshot>[];
    final snapshots = <SaveSnapshot>[];
    await for (final entity in backups.list()) {
      if (entity is! File || path.extension(entity.path) != '.sav') continue;
      final stat = await entity.stat();
      snapshots.add(SaveSnapshot(
        path: entity.path,
        modifiedAt: stat.modified,
        size: stat.size,
      ));
    }
    snapshots.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return snapshots;
  }

  Future<File> restoreBackup({
    required String root,
    required String gameId,
    required String backupPath,
  }) async {
    final source = File(backupPath);
    if (!await source.exists()) {
      throw const FileSystemException('Backup não encontrado.');
    }
    final directory = gameDirectory(root, gameId);
    await directory.create(recursive: true);
    return source.copy(path.join(directory.path, 'save.sav'));
  }

  Future<File> _backup(
    String root,
    String gameId,
    File source,
    String phase,
  ) async {
    final directory = Directory(
      path.join(gameDirectory(root, gameId).path, 'backups'),
    );
    await directory.create(recursive: true);
    final now = DateTime.now().toUtc();
    final stamp = now.toIso8601String().replaceAll(':', '-');
    return source.copy(path.join(directory.path, '$stamp-$phase.sav'));
  }

  String _safeId(String value) =>
      value.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
}
