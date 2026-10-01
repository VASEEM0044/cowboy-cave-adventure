import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../game/cowboy_cave_game.dart';

/// Modal overlay displayed when the player successfully reaches the unlocked Exit Gate.
class LevelCompleteOverlay extends StatelessWidget {
  const LevelCompleteOverlay({
    super.key,
    required this.game,
  });

  final CowboyCaveGame game;

  void _onReplay() {
    game.restartLevel();
  }

  void _onNextLevel(BuildContext context) {
    if (game.levelNumber < AppConstants.totalLevels) {
      Navigator.of(context).pushReplacementNamed(
        AppRouter.gamePlay,
        arguments: game.levelNumber + 1,
      );
    } else {
      // Reached final level -> return to level select
      Navigator.of(context).pushReplacementNamed(AppRouter.levelSelect);
    }
  }

  void _onMenu(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRouter.dashboard,
      (route) => false,
    );
  }

  int _calculateStars(int score, int coins, int totalCoins) {
    if (totalCoins > 0 && coins >= totalCoins && score >= 150) {
      return 3;
    } else if (coins >= (totalCoins * 0.5) || score >= 80) {
      return 2;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final finalScore = game.scoreNotifier.value;
    final finalCoins = game.coinsNotifier.value;
    final totalCoins = game.totalCoins;
    final stars = _calculateStars(finalScore, finalCoins, totalCoins);

    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(200),
        child: Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: AppConstants.colorSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppConstants.colorSecondary,
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
                // Header Title
                const Text(
                  'LEVEL COMPLETE!',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.colorSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),

                // Star Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isEarned = index < stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        isEarned ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 32,
                        color: isEarned ? const Color(0xFFFFD54F) : AppConstants.colorTextMuted,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),

                // Score and Coin Stats
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppConstants.colorSurfaceLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppConstants.colorBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SCORE',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamily,
                              fontSize: 8,
                              color: AppConstants.colorTextMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$finalScore',
                            style: const TextStyle(
                              fontFamily: AppConstants.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.colorPrimary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'COINS',
                            style: TextStyle(
                              fontFamily: AppConstants.fontFamily,
                              fontSize: 8,
                              color: AppConstants.colorTextMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$finalCoins / $totalCoins',
                            style: const TextStyle(
                              fontFamily: AppConstants.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.colorSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Replay Button
                _LevelCompleteButton(
                  label: 'REPLAY',
                  icon: Icons.refresh_rounded,
                  color: AppConstants.colorSurfaceLight,
                  textColor: AppConstants.colorTextPrimary,
                  onPressed: _onReplay,
                ),
                const SizedBox(height: 8),

                // Next Level Button
                _LevelCompleteButton(
                  label: game.levelNumber < AppConstants.totalLevels ? 'NEXT LEVEL' : 'LEVEL SELECT',
                  icon: Icons.arrow_forward_rounded,
                  color: AppConstants.colorSecondary,
                  textColor: Colors.black,
                  onPressed: () => _onNextLevel(context),
                ),
                const SizedBox(height: 8),

                // Menu Button
                _LevelCompleteButton(
                  label: 'MENU',
                  icon: Icons.home_rounded,
                  color: AppConstants.colorSurfaceLight,
                  textColor: AppConstants.colorTextMuted,
                  onPressed: () => _onMenu(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelCompleteButton extends StatelessWidget {
  const _LevelCompleteButton({
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
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
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
              Icon(icon, size: 15, color: textColor),
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
