import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

final class _NativeSessionConfig extends Struct {
  external Pointer<Utf8> romPath;
  external Pointer<Utf8> savePath;

  @Int32()
  external int enableAudio;
}

typedef _BackendAvailableNative = Int32 Function();
typedef _BackendAvailableDart = int Function();
typedef _CreateNative = Int32 Function(
  Pointer<_NativeSessionConfig>,
  Pointer<Pointer<Void>>,
);
typedef _CreateDart = int Function(
  Pointer<_NativeSessionConfig>,
  Pointer<Pointer<Void>>,
);
typedef _RunFrameNative = Int32 Function(Pointer<Void>);
typedef _RunFrameDart = int Function(Pointer<Void>);
typedef _ResetNative = Int32 Function(Pointer<Void>);
typedef _ResetDart = int Function(Pointer<Void>);
typedef _SetButtonNative = Int32 Function(Pointer<Void>, Int32, Int32);
typedef _SetButtonDart = int Function(Pointer<Void>, int, int);
typedef _CopyFramebufferNative = Int32 Function(
  Pointer<Void>,
  Pointer<Uint8>,
  Size,
);
typedef _CopyFramebufferDart = int Function(
  Pointer<Void>,
  Pointer<Uint8>,
  int,
);
typedef _ReadAudioNative = Size Function(
  Pointer<Void>,
  Pointer<Int16>,
  Size,
);
typedef _ReadAudioDart = int Function(
  Pointer<Void>,
  Pointer<Int16>,
  int,
);
typedef _AudioRateNative = Uint32 Function(Pointer<Void>);
typedef _AudioRateDart = int Function(Pointer<Void>);
typedef _FlushSaveNative = Int32 Function(Pointer<Void>);
typedef _FlushSaveDart = int Function(Pointer<Void>);
typedef _DestroyNative = Void Function(Pointer<Void>);
typedef _DestroyDart = void Function(Pointer<Void>);

class NativeEmulatorException implements Exception {
  const NativeEmulatorException(this.message, [this.resultCode]);

  final String message;
  final int? resultCode;

  @override
  String toString() => message;
}

enum GbaButton {
  a,
  b,
  select,
  start,
  right,
  left,
  up,
  down,
  r,
  l,
}

class NativeEmulator {
  NativeEmulator._(this._library)
      : _backendAvailable = _library.lookupFunction<
            _BackendAvailableNative,
            _BackendAvailableDart>('emugba_session_backend_available'),
        _create = _library.lookupFunction<_CreateNative, _CreateDart>(
          'emugba_session_create',
        ),
        _runFrame = _library.lookupFunction<_RunFrameNative, _RunFrameDart>(
          'emugba_session_run_frame',
        ),
        _reset = _library.lookupFunction<_ResetNative, _ResetDart>(
          'emugba_session_reset',
        ),
        _setButton = _library.lookupFunction<_SetButtonNative, _SetButtonDart>(
          'emugba_session_set_button',
        ),
        _copyFramebuffer = _library.lookupFunction<
            _CopyFramebufferNative,
            _CopyFramebufferDart>('emugba_session_copy_framebuffer'),
        _readAudio = _library.lookupFunction<_ReadAudioNative, _ReadAudioDart>(
          'emugba_session_read_audio',
        ),
        _audioRate = _library.lookupFunction<_AudioRateNative, _AudioRateDart>(
          'emugba_session_audio_sample_rate',
        ),
        _flushSave = _library.lookupFunction<
            _FlushSaveNative,
            _FlushSaveDart>('emugba_session_flush_save'),
        _destroy = _library.lookupFunction<_DestroyNative, _DestroyDart>(
          'emugba_session_destroy',
        );

  static const frameWidth = 240;
  static const frameHeight = 160;
  static const frameBytes = frameWidth * frameHeight * 4;

  final DynamicLibrary _library;
  final _BackendAvailableDart _backendAvailable;
  final _CreateDart _create;
  final _RunFrameDart _runFrame;
  final _ResetDart _reset;
  final _SetButtonDart _setButton;
  final _CopyFramebufferDart _copyFramebuffer;
  final _ReadAudioDart _readAudio;
  final _AudioRateDart _audioRate;
  final _FlushSaveDart _flushSave;
  final _DestroyDart _destroy;

  Pointer<Void> _session = nullptr;

  static NativeEmulator open() {
    final override = Platform.environment['EMUGBA_CORE_LIBRARY'];
    final candidates = <String>[
      if (override != null && override.isNotEmpty) override,
      if (Platform.isLinux) ...<String>[
        'libemuladorgba_core.so',
        '../../build/libemuladorgba_core.so',
        '../../build/Release/libemuladorgba_core.so',
      ],
      if (Platform.isWindows) ...<String>[
        'emuladorgba_core.dll',
        r'..\..\build\Release\emuladorgba_core.dll',
        r'..\..\build\emuladorgba_core.dll',
      ],
      if (Platform.isMacOS) ...<String>[
        'libemuladorgba_core.dylib',
        '../../build/libemuladorgba_core.dylib',
      ],
    ];

    Object? lastError;
    for (final candidate in candidates) {
      try {
        return NativeEmulator._(DynamicLibrary.open(candidate));
      } on Object catch (error) {
        lastError = error;
      }
    }
    throw NativeEmulatorException(
      'Biblioteca nativa não encontrada. Compile o núcleo com CMake. '
      'Detalhe: $lastError',
    );
  }

  bool get backendAvailable => _backendAvailable() != 0;
  bool get isOpen => _session != nullptr;
  int get audioSampleRate => isOpen ? _audioRate(_session) : 0;

  void start({
    required String romPath,
    required String savePath,
    bool enableAudio = true,
  }) {
    if (isOpen) {
      throw const NativeEmulatorException('Já existe uma sessão aberta.');
    }
    if (!backendAvailable) {
      throw const NativeEmulatorException(
        'O núcleo foi compilado sem o backend mGBA.',
      );
    }

    final config = calloc<_NativeSessionConfig>();
    final output = calloc<Pointer<Void>>();
    final rom = romPath.toNativeUtf8();
    final save = savePath.toNativeUtf8();
    try {
      config.ref
        ..romPath = rom
        ..savePath = save
        ..enableAudio = enableAudio ? 1 : 0;
      final result = _create(config, output);
      if (result != 0) {
        throw NativeEmulatorException(
          'Não foi possível iniciar o núcleo mGBA.',
          result,
        );
      }
      _session = output.value;
    } finally {
      calloc.free(rom);
      calloc.free(save);
      calloc.free(config);
      calloc.free(output);
    }
  }

  Uint8List runFrame() {
    _requireSession();
    final result = _runFrame(_session);
    if (result != 0) {
      throw NativeEmulatorException('Falha ao executar frame.', result);
    }

    final buffer = calloc<Uint8>(frameBytes);
    try {
      final copyResult = _copyFramebuffer(_session, buffer, frameBytes);
      if (copyResult != 0) {
        throw NativeEmulatorException(
          'Falha ao copiar o framebuffer.',
          copyResult,
        );
      }
      return Uint8List.fromList(buffer.asTypedList(frameBytes));
    } finally {
      calloc.free(buffer);
    }
  }

  Int16List readAudio({int maximumFrames = 2048}) {
    _requireSession();
    final buffer = calloc<Int16>(maximumFrames * 2);
    try {
      final frames = _readAudio(_session, buffer, maximumFrames);
      return Int16List.fromList(buffer.asTypedList(frames * 2));
    } finally {
      calloc.free(buffer);
    }
  }

  void setButton(GbaButton button, bool pressed) {
    _requireSession();
    final result = _setButton(_session, button.index, pressed ? 1 : 0);
    if (result != 0) {
      throw NativeEmulatorException('Falha ao enviar controle.', result);
    }
  }

  void reset() {
    _requireSession();
    final result = _reset(_session);
    if (result != 0) {
      throw NativeEmulatorException('Falha ao reiniciar o jogo.', result);
    }
  }

  void flushSave() {
    if (!isOpen) return;
    final result = _flushSave(_session);
    if (result != 0) {
      throw NativeEmulatorException('Falha ao gravar o save.', result);
    }
  }

  void close() {
    if (!isOpen) return;
    _destroy(_session);
    _session = nullptr;
  }

  void _requireSession() {
    if (!isOpen) {
      throw const NativeEmulatorException('Nenhuma sessão está aberta.');
    }
  }
}
