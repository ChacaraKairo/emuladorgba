import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

import '../models/game_entry.dart';
import '../services/native_emulator.dart';
import '../services/pcm_audio_sink.dart';
import '../theme/app_colors.dart';

class IntegratedPlayerScreen extends StatefulWidget {
  const IntegratedPlayerScreen({required this.game, super.key});

  final GameEntry game;

  @override
  State<IntegratedPlayerScreen> createState() =>
      _IntegratedPlayerScreenState();
}

class _IntegratedPlayerScreenState extends State<IntegratedPlayerScreen> {
  final FocusNode _focusNode = FocusNode();
  final PcmAudioSink _audioSink = PcmAudioSink();
  final Set<LogicalKeyboardKey> _pressedKeys = <LogicalKeyboardKey>{};

  NativeEmulator? _emulator;
  Timer? _frameTimer;
  ui.Image? _image;
  String? _error;
  bool _paused = false;
  bool _decodingFrame = false;

  static const Duration _frameDuration = Duration(microseconds: 16742);

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final emulator = NativeEmulator.open();
      final savePath = path.setExtension(widget.game.romPath, '.sav');
      emulator.start(
        romPath: widget.game.romPath,
        savePath: savePath,
        enableAudio: true,
      );
      _emulator = emulator;
      await _audioSink.start(emulator.audioSampleRate);
      _frameTimer = Timer.periodic(_frameDuration, (_) => _tick());
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  void _tick() {
    final emulator = _emulator;
    if (emulator == null || _paused || _decodingFrame || !mounted) return;

    try {
      final pixels = emulator.runFrame();
      _audioSink.add(emulator.readAudio());
      _decodeFrame(pixels);
    } on Object catch (error) {
      _frameTimer?.cancel();
      setState(() => _error = error.toString());
    }
  }

  void _decodeFrame(Uint8List pixels) {
    _decodingFrame = true;
    ui.decodeImageFromPixels(
      pixels,
      NativeEmulator.frameWidth,
      NativeEmulator.frameHeight,
      ui.PixelFormat.rgba8888,
      (image) {
        _decodingFrame = false;
        if (!mounted) {
          image.dispose();
          return;
        }
        final previous = _image;
        setState(() => _image = image);
        previous?.dispose();
      },
    );
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    final button = _buttonForKey(event.logicalKey);
    if (button == null) return KeyEventResult.ignored;

    final pressed = event is KeyDownEvent || event is KeyRepeatEvent;
    if (pressed) {
      if (_pressedKeys.add(event.logicalKey)) {
        _emulator?.setButton(button, true);
      }
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
      _emulator?.setButton(button, false);
    }
    return KeyEventResult.handled;
  }

  GbaButton? _buttonForKey(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.keyX) return GbaButton.a;
    if (key == LogicalKeyboardKey.keyZ) return GbaButton.b;
    if (key == LogicalKeyboardKey.enter) return GbaButton.start;
    if (key == LogicalKeyboardKey.backspace) return GbaButton.select;
    if (key == LogicalKeyboardKey.arrowRight) return GbaButton.right;
    if (key == LogicalKeyboardKey.arrowLeft) return GbaButton.left;
    if (key == LogicalKeyboardKey.arrowUp) return GbaButton.up;
    if (key == LogicalKeyboardKey.arrowDown) return GbaButton.down;
    if (key == LogicalKeyboardKey.keyS) return GbaButton.r;
    if (key == LogicalKeyboardKey.keyA) return GbaButton.l;
    return null;
  }

  void _setButton(GbaButton button, bool pressed) {
    try {
      _emulator?.setButton(button, pressed);
    } on Object catch (error) {
      setState(() => _error = error.toString());
    }
  }

  Future<void> _closePlayer() async {
    _frameTimer?.cancel();
    try {
      _emulator?.flushSave();
    } on Object {
      // A destruição da sessão tenta gravar novamente antes de liberar o núcleo.
    }
    _emulator?.close();
    _emulator = null;
    await _audioSink.close();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _emulator?.close();
    _audioSink.close();
    _image?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _closePlayer();
      },
      child: Scaffold(
        backgroundColor: AppColors.brandBlueDark,
        appBar: AppBar(
          title: Text(widget.game.title),
          leading: IconButton(
            tooltip: 'Fechar e salvar',
            onPressed: _closePlayer,
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              tooltip: _paused ? 'Continuar' : 'Pausar',
              onPressed: () => setState(() => _paused = !_paused),
              icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
            ),
            IconButton(
              tooltip: 'Reiniciar',
              onPressed: () => _emulator?.reset(),
              icon: const Icon(Icons.restart_alt),
            ),
          ],
        ),
        body: Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKey,
          child: SafeArea(
            child: _error == null ? _buildPlayer() : _buildError(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 850;
        final display = _GameDisplay(image: _image, paused: _paused);
        final controls = _Controls(onButton: _setButton);
        return Padding(
          padding: const EdgeInsets.all(16),
          child: wide
              ? Row(
                  children: [
                    Expanded(flex: 3, child: display),
                    const SizedBox(width: 20),
                    SizedBox(width: 330, child: controls),
                  ],
                )
              : Column(
                  children: [
                    Expanded(child: display),
                    const SizedBox(height: 12),
                    controls,
                  ],
                ),
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56),
                const SizedBox(height: 16),
                Text(
                  'Não foi possível iniciar o modo integrado',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _closePlayer,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameDisplay extends StatelessWidget {
  const _GameDisplay({required this.image, required this.paused});

  final ui.Image? image;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ColoredBox(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (image == null)
                  const Center(child: CircularProgressIndicator())
                else
                  CustomPaint(painter: _FramePainter(image!)),
                if (paused)
                  ColoredBox(
                    color: Colors.black54,
                    child: Center(
                      child: Text(
                        'PAUSADO',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  const _FramePainter(this.image);

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final source = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final destination = Offset.zero & size;
    final paint = Paint()..filterQuality = FilterQuality.none;
    canvas.drawImageRect(image, source, destination, paint);
  }

  @override
  bool shouldRepaint(covariant _FramePainter oldDelegate) =>
      oldDelegate.image != image;
}

class _Controls extends StatelessWidget {
  const _Controls({required this.onButton});

  final void Function(GbaButton button, bool pressed) onButton;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _DPad(onButton: onButton),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _HoldButton(
                        label: 'L',
                        onChanged: (value) => onButton(GbaButton.l, value),
                      ),
                      const SizedBox(width: 12),
                      _HoldButton(
                        label: 'R',
                        onChanged: (value) => onButton(GbaButton.r, value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _HoldButton(
                        label: 'SELECT',
                        compact: true,
                        onChanged: (value) => onButton(GbaButton.select, value),
                      ),
                      const SizedBox(width: 10),
                      _HoldButton(
                        label: 'START',
                        compact: true,
                        onChanged: (value) => onButton(GbaButton.start, value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                _HoldButton(
                  label: 'B',
                  onChanged: (value) => onButton(GbaButton.b, value),
                ),
                const SizedBox(width: 10),
                _HoldButton(
                  label: 'A',
                  primary: true,
                  onChanged: (value) => onButton(GbaButton.a, value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DPad extends StatelessWidget {
  const _DPad({required this.onButton});

  final void Function(GbaButton button, bool pressed) onButton;

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, GbaButton gbaButton) => _HoldIconButton(
          icon: icon,
          onChanged: (value) => onButton(gbaButton, value),
        );

    return SizedBox(
      width: 150,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(Icons.keyboard_arrow_up, GbaButton.up),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              button(Icons.keyboard_arrow_left, GbaButton.left),
              const SizedBox(width: 48, height: 48),
              button(Icons.keyboard_arrow_right, GbaButton.right),
            ],
          ),
          button(Icons.keyboard_arrow_down, GbaButton.down),
        ],
      ),
    );
  }
}

class _HoldButton extends StatelessWidget {
  const _HoldButton({
    required this.label,
    required this.onChanged,
    this.primary = false,
    this.compact = false,
  });

  final String label;
  final ValueChanged<bool> onChanged;
  final bool primary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onChanged(true),
      onPointerUp: (_) => onChanged(false),
      onPointerCancel: (_) => onChanged(false),
      child: Container(
        width: compact ? 76 : 62,
        height: compact ? 44 : 62,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary ? AppColors.brandRed : AppColors.brandBlue,
          borderRadius: BorderRadius.circular(compact ? 18 : 31),
          boxShadow: const [BoxShadow(blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _HoldIconButton extends StatelessWidget {
  const _HoldIconButton({required this.icon, required this.onChanged});

  final IconData icon;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onChanged(true),
      onPointerUp: (_) => onChanged(false),
      onPointerCancel: (_) => onChanged(false),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.brandBlueDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 36),
      ),
    );
  }
}
