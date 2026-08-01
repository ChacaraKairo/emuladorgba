import 'dart:io';

class EmulatorLaunchException implements Exception {
  const EmulatorLaunchException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _LaunchTarget {
  const _LaunchTarget(this.executable, this.arguments, {this.runInShell = false});

  final String executable;
  final List<String> arguments;
  final bool runInShell;
}

class EmulatorLauncher {
  static const _flatpakApplicationId = 'io.mgba.mGBA';
  static const _linuxCandidates = <String>['mgba-qt', 'mgba'];
  static const _windowsCandidates = <String>['mgba-qt.exe', 'mgba.exe'];

  Future<String?> _findCommand(List<String> candidates) async {
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

  Future<_LaunchTarget?> _findTarget(String romPath) async {
    if (Platform.isLinux) {
      final flatpak = await _findCommand(const <String>['flatpak']);
      if (flatpak != null) {
        final info = await Process.run(
          flatpak,
          const <String>['info', _flatpakApplicationId],
        );
        if (info.exitCode == 0) {
          return _LaunchTarget(
            flatpak,
            <String>['run', _flatpakApplicationId, romPath],
          );
        }
      }
    }

    final executable = await _findCommand(
      Platform.isWindows ? _windowsCandidates : _linuxCandidates,
    );
    if (executable == null) return null;
    return _LaunchTarget(
      executable,
      <String>[romPath],
      runInShell: Platform.isWindows,
    );
  }

  Future<void> launch(String romPath) async {
    final rom = File(romPath);
    if (!await rom.exists()) {
      throw const EmulatorLaunchException(
        'O arquivo da ROM não está mais disponível neste caminho.',
      );
    }

    final target = await _findTarget(romPath);
    if (target == null) {
      throw const EmulatorLaunchException(
        'mGBA não encontrado. Instale o mGBA por Flatpak ou pelo gerenciador de pacotes do sistema.',
      );
    }

    try {
      await Process.start(
        target.executable,
        target.arguments,
        mode: ProcessStartMode.detached,
        runInShell: target.runInShell,
      );
    } on ProcessException catch (error) {
      throw EmulatorLaunchException(
        'Não foi possível iniciar o mGBA: ${error.message}',
      );
    }
  }
}
