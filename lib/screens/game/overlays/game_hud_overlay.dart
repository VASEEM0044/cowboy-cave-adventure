import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../game/cowboy_cave_game.dart';

/// Top Retro Arcade Game HUD overlay displaying Lives, Score, Coins, and Pause button.
class GameHudOverlay extends StatelessWidget {
  const GameHudOverlay({
    super.key,
    required this.game,
  });

  final CowboyCaveGame game;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 12,
      right: 12,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Top-Left: Player Lives / Hearts
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.colorSurface.withAlpha(220),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppConstants.colorBorder,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'LIFE ',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamily,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.colorTextMuted,
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: game.livesNotifier,
                  builder: (context, lives, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        final isAlive = index < lives;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            isAlive
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isAlive
                                ? AppConstants.colorAccent
                                : AppConstants.colorLocked,
                            size: 16,
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),

          // Top-Center: Stage Indicator & Pause Button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.colorSurface.withAlpha(220),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppConstants.colorBorder,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'STAGE ${game.levelNumber}',
                  style: const TextStyle(
                    fontFamily: AppConstants.fontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.colorPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => game.pauseGame(),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppConstants.colorSurface.withAlpha(220),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppConstants.colorBorder,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.pause_rounded,
                      color: AppConstants.colorTextPrimary,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Top-Right: Coins & Live Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.colorSurface.withAlpha(220),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppConstants.colorBorder,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Coins
                const Icon(
                  Icons.monetization_on_rounded,
                  color: AppConstants.colorPrimary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                ValueListenableBuilder<int>(
                  valueListenable: game.coinsNotifier,
                  builder: (context, coins, _) {
                    return Text(
                      '$coins',
                      style: const TextStyle(
                        fontFamily: AppConstants.fontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.colorTextPrimary,
                      ),
                    );
                  },
                ),

                const SizedBox(width: 12),

                // Score
                const Text(
                  'PTS ',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamily,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.colorTextMuted,
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: game.scoreNotifier,
                  builder: (context, score, _) {
                    return Text(
                      score.toString().padLeft(5, '0'),
                      style: const TextStyle(
                        fontFamily: AppConstants.fontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.colorSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  }
}
