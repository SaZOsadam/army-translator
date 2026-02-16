import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class AudioWaveform extends StatefulWidget {
  final bool isActive;
  final Color? color;

  const AudioWaveform({
    super.key,
    this.isActive = false,
    this.color,
  });

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _amplitudes = List.generate(30, (_) => 0.3);
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    if (widget.isActive) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(AudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  void _startAnimation() {
    _controller.addListener(_updateAmplitudes);
    _controller.repeat();
  }

  void _stopAnimation() {
    _controller.removeListener(_updateAmplitudes);
    _controller.stop();
    setState(() {
      for (var i = 0; i < _amplitudes.length; i++) {
        _amplitudes[i] = 0.3;
      }
    });
  }

  void _updateAmplitudes() {
    setState(() {
      for (var i = 0; i < _amplitudes.length; i++) {
        _amplitudes[i] = 0.2 + _random.nextDouble() * 0.8;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primaryPurple;

    return CustomPaint(
      painter: _WaveformPainter(
        amplitudes: _amplitudes,
        color: color,
        isActive: widget.isActive,
      ),
      size: Size.infinite,
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color color;
  final bool isActive;

  _WaveformPainter({
    required this.amplitudes,
    required this.color,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(isActive ? 0.6 : 0.3)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / amplitudes.length;
    final centerY = size.height / 2;

    for (var i = 0; i < amplitudes.length; i++) {
      final x = i * barWidth + barWidth / 2;
      final amplitude = amplitudes[i];
      final barHeight = size.height * 0.4 * amplitude;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes ||
        oldDelegate.isActive != isActive;
  }
}

class MiniWaveform extends StatelessWidget {
  final bool isActive;
  final double width;
  final double height;

  const MiniWaveform({
    super.key,
    this.isActive = false,
    this.width = 60,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: AudioWaveform(isActive: isActive),
    );
  }
}
