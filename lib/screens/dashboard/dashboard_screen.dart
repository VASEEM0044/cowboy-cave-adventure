import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/audio/audio_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/navigation/app_router.dart';

/// Retro arcade styled Main Menu / Dashboard screen.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Ensure BGM plays on dashboard screen
    AudioController.instance.playBgm();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onPlayPressed() {
    Navigator.of(context).pushNamed(AppRouter.levelSelect);
  }

  void _onExitPressed() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.colorBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Retro Badge / Tagline
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.colorSurfaceLight,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppConstants.colorBorder,
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      'RETRO ARCADE 256x256',
                      style: TextStyle(
                        fontFamily: AppConstants.fontFamily,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: AppConstants.colorSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Main Game Title with Arcade Glowing Effect
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          'COWBOY CAVE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            color: AppConstants.colorPrimary,
                            shadows: const [
                              Shadow(
                                offset: Offset(3, 3),
                                color: Color(0xFF5A3E00),
                              ),
                              Shadow(
                                offset: Offset(0, 0),
                                blurRadius: 12,
                                color: Color(0x66FFB800),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'ADVENTURE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppConstants.fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            letterSpacing: 3,
                            color: AppConstants.colorTextPrimary,
                            shadows: const [
                              Shadow(
                                offset: Offset(2, 2),
                                color: Color(0xFF1E2130),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Navigation Action Buttons
                  SizedBox(
                    width: 240,
                    child: Column(
                      children: [
                        _ArcadeMenuButton(
                          label: 'PLAY GAME',
                          icon: Icons.play_arrow_rounded,
                          accentColor: AppConstants.colorPrimary,
                          textColor: Colors.black,
                          onPressed: _onPlayPressed,
                        ),
                        const SizedBox(height: 12),
                        _ArcadeMenuButton(
                          label: 'EXIT',
                          icon: Icons.exit_to_app_rounded,
                          accentColor: AppConstants.colorSurfaceLight,
                          textColor: AppConstants.colorTextMuted,
                          onPressed: _onExitPressed,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Audio Controls Row (BGM & SFX Mute Toggles)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: AudioController.instance.bgmMutedNotifier,
                        builder: (context, isMuted, _) {
                          return _AudioIconButton(
                            icon: isMuted ? Icons.music_off_rounded : Icons.music_note_rounded,
                            label: isMuted ? 'BGM OFF' : 'BGM ON',
                            isActive: !isMuted,
                            onPressed: () => AudioController.instance.toggleBgm(),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      ValueListenableBuilder<bool>(
                        valueListenable: AudioController.instance.sfxMutedNotifier,
                        builder: (context, isMuted, _) {
                          return _AudioIconButton(
                            icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                            label: isMuted ? 'SFX OFF' : 'SFX ON',
                            isActive: !isMuted,
                            onPressed: () => AudioController.instance.toggleSfx(),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // App Identifier Footer
                  const Text(
                    '${AppConstants.bundleIdentifier} • v${AppConstants.version}',
                    style: TextStyle(
                      fontFamily: AppConstants.fontFamily,
                      fontSize: 8,
                      color: AppConstants.colorTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact retro icon button for audio settings
class _AudioIconButton extends StatelessWidget {
  const _AudioIconButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? AppConstants.colorSurfaceLight
                : AppConstants.colorSurfaceLight.withAlpha(100),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? AppConstants.colorPrimary : AppConstants.colorBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? AppConstants.colorPrimary : AppConstants.colorTextMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamily,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppConstants.colorTextPrimary : AppConstants.colorTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Pixel/Arcade styled menu button with bevelled shadow effect.
class _ArcadeMenuButton extends StatelessWidget {
  const _ArcadeMenuButton({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.textColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
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
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white24,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppConstants.fontFamily,
                  fontSize: 12,
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
