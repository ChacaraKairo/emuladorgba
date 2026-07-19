import 'dart:ffi';
import 'dart:io';

class NativeBridgeStatus {
  const NativeBridgeStatus({required this.available, required this.message});

  final bool available;
  final String message;
}

class NativeBridge {
  DynamicLibrary? _library;

  NativeBridgeStatus load() {
    if (_library != null) {
      return const NativeBridgeStatus(
        available: true,
        message: 'Biblioteca nativa carregada.',
      );
    }

    for (final candidate in _candidates) {
      try {
        final library = DynamicLibrary.open(candidate);
        library.lookup<NativeFunction<Int32 Function()>>(
          'emugba_is_initialized',
        );
        _library = library;
        return NativeBridgeStatus(
          available: true,
          message: 'Biblioteca nativa carregada de $candidate.',
        );
      } on ArgumentError {
        continue;
      }
    }

    return const NativeBridgeStatus(
      available: false,
      message: 'Biblioteca nativa ainda não encontrada. O modo externo continuará disponível.',
    );
  }

  List<String> get _candidates {
    if (Platform.isWindows) {
      return const <String>['emuladorgba_core.dll'];
    }
    if (Platform.isMacOS) {
      return const <String>['libemuladorgba_core.dylib'];
    }
    return const <String>[
      'libemuladorgba_core.so',
      './libemuladorgba_core.so',
    ];
  }
}
