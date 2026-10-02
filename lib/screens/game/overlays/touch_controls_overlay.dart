import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../game/cowboy_cave_game.dart';

/// On-screen translucent multi-touch arcade controls for mobile devices.
///
/// Uses discrete [Listener] pointer events for independent multi-touch
/// processing without gesture competition (e.g. running while jumping).
class TouchControlsOverlay extends StatelessWidget {
  const TouchControlsOverlay({
    super.key,
    required this.game,
  });

  final CowboyCaveGame game;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final horizontalPadding = isLandscape ? 20.0 : 16.0;
    final verticalPadding = isLandscape ? 14.0 : 20.0;
    final buttonSize = isLandscape ? 56.0 : 64.0;
    final jumpSize = isLandscape ? 64.0 : 72.0;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Directional Buttons (Left & Right)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ArcadeTouchButton(
                    icon: Icons.arrow_back_rounded,
                    label: 'LEFT',
                    size: buttonSize,
                    color: AppConstants.colorSurfaceLight.withAlpha(200),
                    activeColor: AppConstants.colorSecondary.withAlpha(220),
                    onPressStart: () => game.player.startMovingLeft(),
                    onPressEnd: () => game.player.stopMovingLeft(),
                  ),
                  SizedBox(width: isLandscape ? 14 : 16),
                  _ArcadeTouchButton(
                    icon: Icons.arrow_forward_rounded,
                    label: 'RIGHT',
                    size: buttonSize,
                    color: AppConstants.colorSurfaceLight.withAlpha(200),
                    activeColor: AppConstants.colorSecondary.withAlpha(220),
                    onPressStart: () => game.player.startMovingRight(),
                    onPressEnd: () => game.player.stopMovingRight(),
                  ),
                ],
              ),

              // Action Buttons (Shoot & Jump)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ArcadeTouchButton(
                    icon: Icons.flash_on_rounded,
                    label: 'SHOOT',
                    size: buttonSize,
                    color: AppConstants.colorAccent.withAlpha(180),
                    activeColor: AppConstants.colorAccent,
                    onPressStart: () => game.player.shoot(),
                    onPressEnd: () {},
                  ),
                  SizedBox(width: isLandscape ? 14 : 16),
                  _ArcadeTouchButton(
                    icon: Icons.arrow_upward_rounded,
                    label: 'JUMP',
                    size: jumpSize,
                    color: AppConstants.colorPrimary.withAlpha(200),
                    activeColor: AppConstants.colorPrimary,
                    onPressStart: () => game.player.jump(),
                    onPressEnd: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Independent pointer-based touch button with tactile feedback.
class _ArcadeTouchButton extends StatefulWidget {
  const _ArcadeTouchButton({
    required this.icon,
    required this.label,
    required this.size,
    required this.color,
    required this.activeColor,
    required this.onPressStart,
    required this.onPressEnd,
  });

  final IconData icon;
  final String label;
  final double size;
  final Color color;
  final Color activeColor;
  final VoidCallback onPressStart;
  final VoidCallback onPressEnd;

  @override
  State<_ArcadeTouchButton> createState() => _ArcadeTouchButtonState();
}

class _ArcadeTouchButtonState extends State<_ArcadeTouchButton> {
  bool _isPressed = false;

  void _handlePointerDown(PointerDownEvent _) {
    setState(() => _isPressed = true);
    widget.onPressStart();
  }

  void _handlePointerUp(PointerUpEvent _) {
    setState(() => _isPressed = false);
    widget.onPressEnd();
  }

  void _handlePointerCancel(PointerCancelEvent _) {
    setState(() => _isPressed = false);
    widget.onPressEnd();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.size,
        height: widget.size,
        transform: _isPressed
            ? Matrix4.translationValues(0, 3, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _isPressed ? widget.activeColor : widget.color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isPressed ? Colors.white : AppConstants.colorBorder,
            width: 2,
          ),
          boxShadow: _isPressed
              ? const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: _isPressed ? Colors.black : Colors.white,
              size: widget.size * 0.42,
            ),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: AppConstants.fontFamily,
                fontSize: 6.5,
                fontWeight: FontWeight.bold,
                color: _isPressed ? Colors.black : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
