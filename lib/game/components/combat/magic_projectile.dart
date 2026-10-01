import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import '../../cowboy_cave_game.dart';
import '../enemies/slime_enemy.dart';
import '../solid_block.dart';

/// A horizontally travelling magic projectile fired by the KnightPlayer.
///
/// Features:
/// - 8x8 visual sprite from `assets/coin.png` (first frame) with a glow tint.
/// - Pure horizontal movement at 260 px/s (NO gravity).
/// - Active [CircleHitbox] for collision detection.
/// - Destroys [SlimeEnemy] on contact (awards +25 score bonus).
/// - Self-removes on [SolidBlock] wall collision.
/// - Self-removes when leaving the 256x256 arena bounds.
class MagicProjectile extends SpriteComponent
    with CollisionCallbacks, HasGameReference<CowboyCaveGame> {
  MagicProjectile({
    required Vector2 startPosition,
    required this.direction,
  }) : super(
          position: startPosition,
          size: Vector2(8, 8),
          anchor: Anchor.center,
        );

  /// Horizontal direction: 1.0 (right) or -1.0 (left).
  final double direction;

  /// Projectile flight speed in pixels per second.
  static const double speed = 260.0;

  /// Whether this projectile has already hit something and is being removed.
  bool _isConsumed = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Use first frame of coin.png as a glowing projectile visual
    final image = await game.images.load('coin.png');
    sprite = Sprite(
      image,
      srcPosition: Vector2.zero(),
      srcSize: Vector2(16, 16),
    );

    // Flip sprite to match travel direction (default faces right)
    if (direction < 0) {
      flipHorizontallyAroundCenter();
    }

    // Attach active circle hitbox for collision detection
    add(CircleHitbox(
      radius: 4,
      position: Vector2(4, 4),
      anchor: Anchor.center,
      collisionType: CollisionType.active,
    ));

    // Add a subtle spinning effect for visual flair
    add(
      RotateEffect.by(
        direction * 6.28, // Full rotation
        EffectController(duration: 0.6, infinite: true),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Pure horizontal movement — NO gravity
    position.x += direction * speed * dt;

    // Remove when leaving the 256x256 arena bounds
    if (position.x < -8 || position.x > 264) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (_isConsumed) return;

    // --- Slime Enemy Hit ---
    final slime = other is SlimeEnemy
        ? other
        : (other.parent is SlimeEnemy ? other.parent as SlimeEnemy : null);

    if (slime != null && !slime.isDead) {
      _isConsumed = true;
      slime.die();
      // Award +25 projectile kill bonus (on top of slime's own 100 bounty)
      game.scoreNotifier.value += 25;
      removeFromParent();
      return;
    }

    // --- Solid Wall Hit ---
    final block = other is SolidBlock
        ? other
        : (other.parent is SolidBlock ? other.parent as SolidBlock : null);

    if (block != null) {
      _isConsumed = true;
      removeFromParent();
      return;
    }
  }
}
