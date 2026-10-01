import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Static environmental solid collision barrier for floors, walls, and platforms.
///
/// Configured with [CollisionType.passive] for maximum collision physics efficiency
/// (passive hitboxes never perform collision checks against other passive hitboxes).
class SolidBlock extends PositionComponent
    with CollisionCallbacks, HasGameReference<FlameGame> {
  SolidBlock({
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.topLeft,
        );

  late final RectangleHitbox hitbox;

  static final Paint _debugFillPaint = Paint()
    ..color = const Color(0x3300E676)
    ..style = PaintingStyle.fill;

  static final Paint _debugStrokePaint = Paint()
    ..color = const Color(0xFFFF0055)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Attach passive static hitbox matching exact dimensions
    hitbox = RectangleHitbox(
      size: size,
      collisionType: CollisionType.passive,
    );
    add(hitbox);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render debug wireframe overlay when game.debugMode is enabled
    if (game.debugMode) {
      final rect = Rect.fromLTWH(0, 0, size.x, size.y);
      canvas.drawRect(rect, _debugFillPaint);
      canvas.drawRect(rect, _debugStrokePaint);
    }
  }
}
