import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/onboarding/bias_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/countdown/countdown_screen.dart';
import '../screens/theory/theory_generator_screen.dart';
import '../screens/theory/theory_detail_screen.dart';
import '../screens/polls/polls_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/premium/premium_screen.dart';
import '../screens/error/error_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String biasSelection = '/bias-selection';
  static const String login = '/login';
  static const String home = '/home';
  static const String countdown = '/countdown';
  static const String theoryGenerator = '/theory-generator';
  static const String theoryDetail = '/theory-detail';
  static const String polls = '/polls';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String premium = '/premium';
  static const String error = '/error';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      case onboarding:
        return _buildRoute(const OnboardingScreen(), settings);
      case biasSelection:
        return _buildRoute(const BiasSelectionScreen(), settings);
      case login:
        return _buildRoute(const LoginScreen(), settings);
      case home:
        return _buildRoute(const HomeScreen(), settings);
      case countdown:
        return _buildRoute(const CountdownScreen(), settings);
      case theoryGenerator:
        return _buildRoute(const TheoryGeneratorScreen(), settings);
      case theoryDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          TheoryDetailScreen(theoryId: args?['theoryId'] ?? ''),
          settings,
        );
      case polls:
        return _buildRoute(const PollsScreen(), settings);
      case profile:
        return _buildRoute(const ProfileScreen(), settings);
      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen(), settings);
      case premium:
        return _buildRoute(const PremiumScreen(), settings);
      case error:
        return _buildRoute(const ErrorScreen(), settings);
      default:
        return _buildRoute(const SplashScreen(), settings);
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
