import 'package:flutter/material.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/game/game_play_screen.dart';
import '../../screens/level_select/level_select_screen.dart';

/// Clean routing system for the game navigation flow.
abstract final class AppRouter {
  static const String dashboard = '/';
  static const String levelSelect = '/level-select';
  static const String gamePlay = '/game';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute<void>(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );

      case levelSelect:
        return MaterialPageRoute<void>(
          builder: (_) => const LevelSelectScreen(),
          settings: settings,
        );

      case gamePlay:
        final args = settings.arguments;
        final levelNumber = args is int ? args : 1;
        return MaterialPageRoute<void>(
          builder: (_) => GamePlayScreen(levelNumber: levelNumber),
          settings: settings,
        );

      default:
        return MaterialPageRoute<void>(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
    }
  }
}
