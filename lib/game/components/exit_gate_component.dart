import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/audio/audio_controller.dart';
import '../cowboy_cave_game.dart';
import 'knight_player.dart';

/// Exit Gate Win Condition component for Cowboy Cave Adventure.
///
/// Features:
/// - Placed at LDtk 'Exit' coordinate (16x16 or 16x24 portal).
/// - Passive [RectangleHitbox] for collision detection.
/// - Locked State: Dim portal frame when remaining coins need collecting.
/// - Unlocked State: Radiant emerald-glowing animated vortex when all coins are collected.
/// - Touching the unlocked gate triggers level victory and displays Level Complete overlay.
class ExitGateComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<CowboyCaveGame> {
  ExitGateComponent({
    required Vector2 position,
    Vector2? size,
  }) : super(
          position: position,
          size: size ?? Vector2(16, 20),
          anchor: Anchor.topLeft,
        );

  bool _isVictoryTriggered = false;
  double _pulseTime = 0.0;

  // Visual paints
  static final Paint _archPaint = Paint()
    ..color = const Color(0xFF3E435E)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  static final Paint _portalClosedPaint = Paint()
    ..color = const Color(0x66FF5252)
    ..style = PaintingStyle.fill;

  static final Paint _portalOpenGlowPaint = Paint()
    ..color = const Color(0x6600E676)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

  static final Paint _portalOpenCorePaint = Paint()
    ..color = const Color(0xFF00E676)
    ..style = PaintingStyle.fill;

  static final Paint _portalStarPaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.fill;

  late final RectangleHitbox gateHitbox;

  /// Whether all level coins are gathered and gate is unlocked.
  bool get isUnlocked {
    if (game.totalCoins == 0) return true;
    return game.coinsNotifier.value >= game.totalCoins;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Attach passive collision hitbox
    gateHitbox = RectangleHitbox(
      position: Vector2(2, 2),
      size: Vector2(size.x - 4, size.y - 2),
      collisionType: CollisionType.passive,
    );
    add(gateHitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(2, 2, size.x - 4, size.y - 2);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));

    if (!isUnlocked) {
      // --- Locked State: Dim / Red Lock Hue ---
      canvas.drawRRect(rrect, _portalClosedPaint);
      canvas.drawRRect(rrect, _archPaint);

      // Draw small lock symbol / dot
      final lockPaint = Paint()..color = const Color(0xFFFFD54F);
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), 2.5, lockPaint);
    } else {
      // --- Unlocked State: Glowing Emerald Portal Vortex ---
      // Outer glow pulse
      final pulse = (math.sin(_pulseTime * 4.0) + 1.0) / 2.0;
      final glowRadius = 4.0 + (pulse * 3.0);
      _portalOpenGlowPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius);

      canvas.drawRRect(rrect, _portalOpenGlowPaint);
      canvas.drawRRect(rrect, _portalOpenCorePaint);
      canvas.drawRRect(rrect, _archPaint);

      // Rotating inner sparkle star
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(_pulseTime * 3.0);
      canvas.drawRect(const Rect.fromLTWH(-2, -2, 4, 4), _portalStarPaint);
      canvas.restore();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (_isVictoryTriggered) return;

    final knight = other is KnightPlayer
        ? other
        : (other.parent is KnightPlayer ? other.parent as KnightPlayer : null);

    if (knight != null) {
      if (isUnlocked) {
        triggerVictory(knight);
      }
    }
  }

  /// Freezes player and triggers level complete state.
  void triggerVictory(KnightPlayer knight) {
    if (_isVictoryTriggered) return;
    _isVictoryTriggered = true;

    // 1. Play victory chime / sound
    AudioController.instance.playCoin();

    // 2. Complete level on game instance
    game.completeLevel();
  }

  /// Resets exit gate state for level replay.
  void reset() {
    _isVictoryTriggered = false;
    _pulseTime = 0.0;
  }
}
