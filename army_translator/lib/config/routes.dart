import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/live/live_view_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/history/session_detail_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/setup/api_setup_screen.dart';
import '../screens/error/error_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String live = '/live';
  static const String history = '/history';
  static const String sessionDetail = '/session-detail';
  static const String settings = '/settings';
  static const String apiSetup = '/api-setup';
  static const String error = '/error';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      
      case onboarding:
        return _buildRoute(const OnboardingScreen(), settings);
      
      case home:
        return _buildRoute(const HomeScreen(), settings);
      
      case live:
        return _buildRoute(const LiveViewScreen(), settings);
      
      case history:
        return _buildRoute(const HistoryScreen(), settings);
      
      case sessionDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          SessionDetailScreen(sessionId: args?['sessionId'] ?? ''),
          settings,
        );
      
      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen(), settings);
      
      case apiSetup:
        return _buildRoute(const ApiSetupScreen(), settings);
      
      case error:
        return _buildRoute(const ErrorScreen(), settings);
      
      default:
        return _buildRoute(const HomeScreen(), settings);
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
