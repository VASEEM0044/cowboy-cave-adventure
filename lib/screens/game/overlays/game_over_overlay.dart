import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../game/cowboy_cave_game.dart';

/// Modal overlay displayed when the player loses all lives.
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.game,
  });

  final CowboyCaveGame game;

  void _onRetry() {
    game.restartLevel();
  }

  void _onQuit(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(200),
        child: Center(
          child: Container(
            width: 280,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: AppConstants.colorSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE53935),
                width: 2.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<int>(
                  valueListenable: game.scoreNotifier,
                  builder: (context, score, _) {
                    return Text(
                      'SCORE: $score',
                      style: const TextStyle(
                        fontFamily: AppConstants.fontFamily,
                        fontSize: 10,
                        color: AppConstants.colorTextMuted,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Retry / Restart Button
                _GameOverButton(
                  label: 'RETRY LEVEL',
                  icon: Icons.refresh_rounded,
                  color: const Color(0xFFE53935),
                  textColor: Colors.white,
                  onPressed: _onRetry,
                ),
                const SizedBox(height: 10),

                // Quit to Menu Button
                _GameOverButton(
                  label: 'QUIT TO MENU',
                  icon: Icons.exit_to_app_rounded,
                  color: AppConstants.colorSurfaceLight,
                  textColor: AppConstants.colorTextMuted,
                  onPressed: () => _onQuit(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameOverButton extends StatelessWidget {
  const _GameOverButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white24,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
