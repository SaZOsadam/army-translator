import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../config/theme.dart';

class LottieAssets {
  static const String loading = 'assets/animations/loading.json';
  static const String success = 'assets/animations/success.json';
  static const String error = 'assets/animations/error.json';
  static const String microphone = 'assets/animations/microphone.json';
  static const String translating = 'assets/animations/translating.json';
  static const String celebration = 'assets/animations/celebration.json';
  static const String heart = 'assets/animations/heart.json';
  static const String listening = 'assets/animations/listening.json';
}

class LoadingAnimation extends StatelessWidget {
  final double size;
  final String? message;

  const LoadingAnimation({
    super.key,
    this.size = 150,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Lottie.asset(
            LottieAssets.loading,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _FallbackLoadingAnimation(size: size);
            },
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ],
    );
  }
}

class _FallbackLoadingAnimation extends StatefulWidget {
  final double size;

  const _FallbackLoadingAnimation({required this.size});

  @override
  State<_FallbackLoadingAnimation> createState() => _FallbackLoadingAnimationState();
}

class _FallbackLoadingAnimationState extends State<_FallbackLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: widget.size * 0.6,
        height: widget.size * 0.6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              AppColors.primaryPurple.withOpacity(0),
              AppColors.primaryPurple,
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: widget.size * 0.5,
            height: widget.size * 0.5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkBg,
            ),
          ),
        ),
      ),
    );
  }
}

class SuccessAnimation extends StatelessWidget {
  final double size;
  final VoidCallback? onComplete;

  const SuccessAnimation({
    super.key,
    this.size = 150,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        LottieAssets.success,
        fit: BoxFit.contain,
        repeat: false,
        onLoaded: (composition) {
          Future.delayed(composition.duration, onComplete);
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.check_circle,
            size: size * 0.6,
            color: AppColors.confidenceHigh,
          );
        },
      ),
    );
  }
}

class ErrorAnimation extends StatelessWidget {
  final double size;

  const ErrorAnimation({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        LottieAssets.error,
        fit: BoxFit.contain,
        repeat: false,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.error_outline,
            size: size * 0.6,
            color: AppColors.confidenceLow,
          );
        },
      ),
    );
  }
}

class MicrophoneAnimation extends StatelessWidget {
  final double size;
  final bool isListening;

  const MicrophoneAnimation({
    super.key,
    this.size = 200,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        LottieAssets.microphone,
        fit: BoxFit.contain,
        animate: isListening,
        errorBuilder: (context, error, stackTrace) {
          return _FallbackMicAnimation(size: size, isActive: isListening);
        },
      ),
    );
  }
}

class _FallbackMicAnimation extends StatefulWidget {
  final double size;
  final bool isActive;

  const _FallbackMicAnimation({required this.size, required this.isActive});

  @override
  State<_FallbackMicAnimation> createState() => _FallbackMicAnimationState();
}

class _FallbackMicAnimationState extends State<_FallbackMicAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_FallbackMicAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: widget.size * 0.6,
        height: widget.size * 0.6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: widget.isActive
              ? AppColors.recordingGradient
              : AppColors.purpleGradient,
          boxShadow: [
            BoxShadow(
              color: (widget.isActive ? AppColors.recording : AppColors.primaryPurple)
                  .withOpacity(0.4),
              blurRadius: 30,
            ),
          ],
        ),
        child: const Icon(Icons.mic, color: Colors.white, size: 48),
      ),
    );
  }
}

class TranslatingAnimation extends StatelessWidget {
  final double size;

  const TranslatingAnimation({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        LottieAssets.translating,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _FallbackTranslatingAnimation(size: size);
        },
      ),
    );
  }
}

class _FallbackTranslatingAnimation extends StatefulWidget {
  final double size;

  const _FallbackTranslatingAnimation({required this.size});

  @override
  State<_FallbackTranslatingAnimation> createState() =>
      _FallbackTranslatingAnimationState();
}

class _FallbackTranslatingAnimationState
    extends State<_FallbackTranslatingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🇰🇷', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 8),
            _buildDot(0),
            _buildDot(1),
            _buildDot(2),
            const SizedBox(width: 8),
            const Text('🇺🇸', style: TextStyle(fontSize: 32)),
          ],
        );
      },
    );
  }

  Widget _buildDot(int index) {
    final progress = ((_controller.value * 3) - index).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryPurple.withOpacity(progress),
      ),
    );
  }
}

class CelebrationAnimation extends StatelessWidget {
  final double size;

  const CelebrationAnimation({super.key, this.size = 300});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        LottieAssets.celebration,
        fit: BoxFit.contain,
        repeat: false,
        errorBuilder: (context, error, stackTrace) {
          return const Text('🎉', style: TextStyle(fontSize: 80));
        },
      ),
    );
  }
}

class HeartAnimation extends StatelessWidget {
  final double size;

  const HeartAnimation({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        LottieAssets.heart,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _FallbackHeartAnimation(size: size);
        },
      ),
    );
  }
}

class _FallbackHeartAnimation extends StatefulWidget {
  final double size;

  const _FallbackHeartAnimation({required this.size});

  @override
  State<_FallbackHeartAnimation> createState() => _FallbackHeartAnimationState();
}

class _FallbackHeartAnimationState extends State<_FallbackHeartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Text('💜', style: TextStyle(fontSize: widget.size * 0.6)),
    );
  }
}
