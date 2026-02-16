import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../config/theme.dart';

class LottieAssets {
  static const String loading = 'assets/animations/loading.json';
  static const String success = 'assets/animations/success.json';
  static const String error = 'assets/animations/error.json';
  static const String celebration = 'assets/animations/celebration.json';
  static const String confetti = 'assets/animations/confetti.json';
  static const String heart = 'assets/animations/heart.json';
  static const String countdown = 'assets/animations/countdown.json';
  static const String trophy = 'assets/animations/trophy.json';
  static const String stars = 'assets/animations/stars.json';
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
              color: AppColors.darkBackground,
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
            color: AppColors.success,
          );
        },
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
        errorBuilder: (context, error, stackTrace) {
          return const Text('🎉', style: TextStyle(fontSize: 80));
        },
      ),
    );
  }
}

class ConfettiAnimation extends StatelessWidget {
  final double width;
  final double height;

  const ConfettiAnimation({
    super.key,
    this.width = double.infinity,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Lottie.asset(
        LottieAssets.confetti,
        fit: BoxFit.cover,
        repeat: false,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox();
        },
      ),
    );
  }
}

class HeartAnimation extends StatelessWidget {
  final double size;
  final bool repeat;

  const HeartAnimation({
    super.key,
    this.size = 100,
    this.repeat = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        LottieAssets.heart,
        fit: BoxFit.contain,
        repeat: repeat,
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

class CountdownAnimation extends StatelessWidget {
  final double size;

  const CountdownAnimation({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        LottieAssets.countdown,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Text('⏰', style: TextStyle(fontSize: 60));
        },
      ),
    );
  }
}

class TrophyAnimation extends StatelessWidget {
  final double size;

  const TrophyAnimation({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        LottieAssets.trophy,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Text('🏆', style: TextStyle(fontSize: 60));
        },
      ),
    );
  }
}

class StarsAnimation extends StatelessWidget {
  final double size;

  const StarsAnimation({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        LottieAssets.stars,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Text('✨', style: TextStyle(fontSize: 60));
        },
      ),
    );
  }
}

class TheoryGeneratingAnimation extends StatelessWidget {
  const TheoryGeneratingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const StarsAnimation(size: 120),
        const SizedBox(height: 16),
        Text(
          'Generating theory...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connecting to BTS Universe 💜',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
