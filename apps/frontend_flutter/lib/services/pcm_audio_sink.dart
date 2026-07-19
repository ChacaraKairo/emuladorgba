import 'dart:io';
import 'dart:typed_data';

class PcmAudioSink {
  Process? _process;
  bool _disabled = false;

  Future<void> start(int sampleRate) async {
    if (!Platform.isLinux || _process != null || _disabled) return;
    try {
      _process = await Process.start(
        'aplay',
        <String>[
          '-q',
          '-t',
          'raw',
          '-f',
          'S16_LE',
          '-c',
          '2',
          '-r',
          sampleRate.toString(),
        ],
        mode: ProcessStartMode.normal,
      );
      _process!.stderr.drain<void>();
    } on ProcessException {
      _disabled = true;
    }
  }

  void add(Int16List samples) {
    final process = _process;
    if (process == null || samples.isEmpty) return;
    final bytes = samples.buffer.asUint8List(
      samples.offsetInBytes,
      samples.lengthInBytes,
    );
    process.stdin.add(bytes);
  }

  Future<void> close() async {
    final process = _process;
    _process = null;
    if (process == null) return;
    await process.stdin.close();
    process.kill();
  }
}
