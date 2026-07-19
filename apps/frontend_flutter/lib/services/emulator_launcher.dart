import 'dart:io';

class EmulatorLaunchException implements Exception {
  const EmulatorLaunchException(this.message);

  final String message;

  @override
  String toString() => message;
}

class EmulatorLauncher {
  static const _linuxCandidates = <String>['mgba-qt', 'mgba'];
  static const _windowsCandidates = <String>['mgba-qt.exe', 'mgba.exe'];

  Future<String?> findExecutable() async {
    final candidates = Platform.isWindows
        ? _windowsCandidates
        : _linuxCandidates;

    for (final candidate in candidates) {
      final result = await Process.run(
        Platform.isWindows ? 'where' : 'which',
        <String>[candidate],
        runInShell: Platform.isWindows,
      );
      if (result.exitCode == 0) {
        final output = (result.stdout as String).trim();
        if (output.isNotEmpty) {
          return output.split(RegExp(r'[\r\n]+')).first;
        }
      }
    }
    return null;
  }

  Future<void> launch(String romPath) async {
    final rom = File(romPath);
    if (!await rom.exists()) {
      throw const EmulatorLaunchException(
        'O arquivo da ROM não está mais disponível neste caminho.',
      );
    }

    final executable = await findExecutable();
    if (executable == null) {
      throw const EmulatorLaunchException(
        'mGBA não encontrado. Instale o pacote mGBA para iniciar os jogos.',
      );
    }

    try {
      await Process.start(
        executable,
        <String>[romPath],
        mode: ProcessStartMode.detached,
        runInShell: Platform.isWindows,
      );
    } on ProcessException catch (error) {
      throw EmulatorLaunchException(
        'Não foi possível iniciar o mGBA: ${error.message}',
      );
    }
  }
}
