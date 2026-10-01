import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../game/cowboy_cave_game.dart';
import 'overlays/game_hud_overlay.dart';
import 'overlays/game_over_overlay.dart';
import 'overlays/level_complete_overlay.dart';
import 'overlays/pause_menu_overlay.dart';
import 'overlays/touch_controls_overlay.dart';

/// Game Play Screen hosting the Flame GameWidget and arcade UI overlays.
class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({
    super.key,
    required this.levelNumber,
  });

  final int levelNumber;

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late final CowboyCaveGame _game;

  @override
  void initState() {
    super.initState();
    _game = CowboyCaveGame(
      levelNumber: widget.levelNumber,
      enableDebugMode: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.colorBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Centered 256x256 Flame Game Arena
            Center(
              child: AspectRatio(
                aspectRatio: AppConstants.virtualWidth / AppConstants.virtualHeight,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppConstants.colorBorder,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black87,
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: GameWidget(game: _game),
                ),
              ),
            ),

            // 2. Top In-Game Arcade HUD (Lives, Stage, Pause Button, Coins, Score)
            GameHudOverlay(game: _game),

            // 3. Bottom Multi-Touch Virtual Controls (Left/Right & Jump/Shoot)
            TouchControlsOverlay(game: _game),

            // 4. Modal In-Game Pause Menu
            ValueListenableBuilder<bool>(
              valueListenable: _game.isPausedNotifier,
              builder: (context, isPaused, _) {
                if (!isPaused) return const SizedBox.shrink();
                return PauseMenuOverlay(game: _game);
              },
            ),

            // 5. Modal In-Game Game Over Screen
            ValueListenableBuilder<int>(
              valueListenable: _game.livesNotifier,
              builder: (context, lives, _) {
                if (lives > 0) return const SizedBox.shrink();
                return GameOverOverlay(game: _game);
              },
            ),

            // 6. Modal In-Game Level Complete Screen
            ValueListenableBuilder<bool>(
              valueListenable: _game.isLevelCompleteNotifier,
              builder: (context, isComplete, _) {
                if (!isComplete) return const SizedBox.shrink();
                return LevelCompleteOverlay(game: _game);
              },
            ),
          ],
        ),
      ),
    );
  }
}
