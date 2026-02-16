import 'dart:async';
import 'package:flutter/material.dart';
import '../config/constants.dart';

class CountdownTimer extends StatefulWidget {
  final bool compact;

  const CountdownTimer({
    super.key,
    this.compact = false,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _timeRemaining;

  @override
  void initState() {
    super.initState();
    _calculateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateTimeRemaining();
    });
  }

  void _calculateTimeRemaining() {
    final now = DateTime.now();
    final releaseDate = AppConstants.albumReleaseDate;
    
    setState(() {
      _timeRemaining = releaseDate.difference(now);
      if (_timeRemaining.isNegative) {
        _timeRemaining = Duration.zero;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    if (_timeRemaining == Duration.zero) {
      return _buildReleasedState();
    }

    if (widget.compact) {
      return _buildCompactTimer(days, hours, minutes, seconds);
    }

    return _buildFullTimer(days, hours, minutes, seconds);
  }

  Widget _buildReleasedState() {
    return Column(
      children: [
        const Text(
          '🎉',
          style: TextStyle(fontSize: 48),
        ),
        const SizedBox(height: 8),
        Text(
          'ARIRANG IS HERE!',
          style: TextStyle(
            fontSize: widget.compact ? 18 : 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTimer(int days, int hours, int minutes, int seconds) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCompactUnit(days, 'D'),
        _buildCompactSeparator(),
        _buildCompactUnit(hours, 'H'),
        _buildCompactSeparator(),
        _buildCompactUnit(minutes, 'M'),
        _buildCompactSeparator(),
        _buildCompactUnit(seconds, 'S'),
      ],
    );
  }

  Widget _buildCompactUnit(int value, String label) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 10,
              ),
        ),
      ],
    );
  }

  Widget _buildCompactSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  Widget _buildFullTimer(int days, int hours, int minutes, int seconds) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeUnit(days, 'DAYS'),
        _buildFullSeparator(),
        _buildTimeUnit(hours, 'HOURS'),
        _buildFullSeparator(),
        _buildTimeUnit(minutes, 'MINS'),
        _buildFullSeparator(),
        _buildTimeUnit(seconds, 'SECS'),
      ],
    );
  }

  Widget _buildTimeUnit(int value, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildFullSeparator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}
