import 'package:flutter/material.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../game/cowboy_cave_game.dart';

/// Modal overlay displayed when the game is paused.
class PauseMenuOverlay extends StatelessWidget {
  const PauseMenuOverlay({
    super.key,
    required this.game,
  });

  final CowboyCaveGame game;

  void _onResume() {
    game.resumeGame();
  }

  void _onRestart(BuildContext context) {
    game.restartLevel();
  }

  void _onQuit(BuildContext context) {
    game.resumeGame(); // resume so engine isn't permanently paused
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(190),
        child: Center(
          child: Container(
            width: 280,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: AppConstants.colorSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppConstants.colorPrimary,
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
                  'PAUSED',
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.colorPrimary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),

                // Audio Quick Toggles
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: AudioController.instance.bgmMutedNotifier,
                      builder: (context, isMuted, _) {
                        return _AudioToggleChip(
                          icon: isMuted ? Icons.music_off_rounded : Icons.music_note_rounded,
                          label: isMuted ? 'BGM' : 'BGM',
                          isMuted: isMuted,
                          onPressed: () => AudioController.instance.toggleBgm(),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    ValueListenableBuilder<bool>(
                      valueListenable: AudioController.instance.sfxMutedNotifier,
                      builder: (context, isMuted, _) {
                        return _AudioToggleChip(
                          icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                          label: isMuted ? 'SFX' : 'SFX',
                          isMuted: isMuted,
                          onPressed: () => AudioController.instance.toggleSfx(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Resume Button
                _PauseMenuButton(
                  label: 'RESUME',
                  icon: Icons.play_arrow_rounded,
                  color: AppConstants.colorPrimary,
                  textColor: Colors.black,
                  onPressed: _onResume,
                ),
                const SizedBox(height: 10),

                // Restart Button
                _PauseMenuButton(
                  label: 'RESTART',
                  icon: Icons.refresh_rounded,
                  color: AppConstants.colorSurfaceLight,
                  textColor: AppConstants.colorTextPrimary,
                  onPressed: () => _onRestart(context),
                ),
                const SizedBox(height: 10),

                // Quit Button
                _PauseMenuButton(
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

class _AudioToggleChip extends StatelessWidget {
  const _AudioToggleChip({
    required this.icon,
    required this.label,
    required this.isMuted,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool isMuted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isMuted ? AppConstants.colorSurfaceLight.withAlpha(120) : AppConstants.colorSurfaceLight,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isMuted ? AppConstants.colorBorder : AppConstants.colorPrimary,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isMuted ? AppConstants.colorTextMuted : AppConstants.colorPrimary,
              ),
              const SizedBox(width: 5),
              Text(
                '$label ${isMuted ? "OFF" : "ON"}',
                style: TextStyle(
                  fontFamily: AppConstants.fontFamily,
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                  color: isMuted ? AppConstants.colorTextMuted : AppConstants.colorTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PauseMenuButton extends StatelessWidget {
  const _PauseMenuButton({
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
