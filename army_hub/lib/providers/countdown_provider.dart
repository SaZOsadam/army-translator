import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';

class CountdownState {
  final Duration timeRemaining;
  final bool isReleased;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  CountdownState({
    required this.timeRemaining,
    required this.isReleased,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  factory CountdownState.fromDuration(Duration duration) {
    final isNegative = duration.isNegative;
    final d = isNegative ? Duration.zero : duration;

    return CountdownState(
      timeRemaining: d,
      isReleased: isNegative || d == Duration.zero,
      days: d.inDays,
      hours: d.inHours % 24,
      minutes: d.inMinutes % 60,
      seconds: d.inSeconds % 60,
    );
  }

  String get formattedCountdown {
    if (isReleased) return 'ARIRANG IS HERE! 🎉';
    
    if (days > 0) {
      return '$days days, $hours hours, $minutes minutes';
    } else if (hours > 0) {
      return '$hours hours, $minutes minutes, $seconds seconds';
    } else if (minutes > 0) {
      return '$minutes minutes, $seconds seconds';
    } else {
      return '$seconds seconds';
    }
  }

  String get shortCountdown {
    if (isReleased) return 'OUT NOW!';
    return '${days}d ${hours}h ${minutes}m ${seconds}s';
  }
}

class CountdownNotifier extends StateNotifier<CountdownState> {
  Timer? _timer;

  CountdownNotifier() : super(_calculateState()) {
    _startTimer();
  }

  static CountdownState _calculateState() {
    final now = DateTime.now();
    final releaseDate = AppConstants.albumReleaseDate;
    final duration = releaseDate.difference(now);
    return CountdownState.fromDuration(duration);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = _calculateState();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final countdownProvider = StateNotifierProvider<CountdownNotifier, CountdownState>((ref) {
  return CountdownNotifier();
});

// Milestone provider
final milestonesProvider = Provider<List<Milestone>>((ref) {
  final countdown = ref.watch(countdownProvider);
  
  return [
    Milestone(
      label: '30 Days',
      days: 30,
      emoji: '🎉',
      isPassed: countdown.days <= 30,
    ),
    Milestone(
      label: '2 Weeks',
      days: 14,
      emoji: '✨',
      isPassed: countdown.days <= 14,
    ),
    Milestone(
      label: '1 Week',
      days: 7,
      emoji: '🔥',
      isPassed: countdown.days <= 7,
    ),
    Milestone(
      label: '3 Days',
      days: 3,
      emoji: '💜',
      isPassed: countdown.days <= 3,
    ),
    Milestone(
      label: '1 Day',
      days: 1,
      emoji: '🚀',
      isPassed: countdown.days <= 1,
    ),
    Milestone(
      label: 'Release!',
      days: 0,
      emoji: '🎵',
      isPassed: countdown.isReleased,
    ),
  ];
});

class Milestone {
  final String label;
  final int days;
  final String emoji;
  final bool isPassed;

  Milestone({
    required this.label,
    required this.days,
    required this.emoji,
    required this.isPassed,
  });
}
