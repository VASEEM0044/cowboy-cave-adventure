import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/animation.dart';
import '../../../core/audio/audio_controller.dart';
import '../../cowboy_cave_game.dart';
import '../knight_player.dart';
import '../solid_block.dart';

/// Autonomous patrolling green slime enemy.
///
/// Features:
/// - 24x24 crawling walk animation from `assets/slime_green.png`.
/// - Horizontal platform patrol AI with solid wall and platform edge turnaround.
/// - Active hazard hitbox dealing contact damage and knockback to KnightPlayer.
/// - Public `die()` method with squashing animation for projectile combat.
class SlimeEnemy extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<CowboyCaveGame> {
  SlimeEnemy({
    Vector2? spawnPosition,
    Vector2? position,
    this.initialDirection = -1,
  })  : _spawnPosition = (spawnPosition ?? position ?? Vector2.zero()).clone(),
        super(
          position: spawnPosition ?? position ?? Vector2.zero(),
          size: Vector2(24, 24),
          anchor: Anchor.topLeft,
        );

  final Vector2 _spawnPosition;
  int initialDirection;

  // Patrol physics constants
  static const double moveSpeed = 35.0;

  int direction = -1; // -1: Left, 1: Right
  bool isFacingRight = false;
  bool isDead = false;

  late final RectangleHitbox hazardHitbox;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    direction = initialDirection;
    isFacingRight = direction > 0;

    // Load 4-frame crawling walk animation from slime_green.png (24x24 frames)
    final image = await game.images.load('slime_green.png');
    final spriteSheet = SpriteSheet(
      image: image,
      srcSize: Vector2(24, 24),
    );

    animation = spriteSheet.createAnimation(
      row: 0,
      stepTime: 0.12,
      from: 0,
      to: 4,
    );

    // Attach active hazard hitbox
    hazardHitbox = RectangleHitbox(
      position: Vector2(3, 8),
      size: Vector2(18, 16),
      collisionType: CollisionType.active,
    );
    add(hazardHitbox);

    if (isFacingRight) {
      flipHorizontallyAroundCenter();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDead) return;

    // 1. Move horizontally along current patrol direction
    position.x += direction * moveSpeed * dt;

    if (isMounted) {
      // 2. Check for platform edges / cliffs ahead
      _checkPlatformEdge();

      // 3. Check for screen outer boundary walls
      _checkLevelBounds();
    }

    // 4. Update horizontal facing direction
    _updateFacingDirection();
  }

  /// Reverses patrol direction when a platform edge or cliff is reached.
  void _checkPlatformEdge() {
    // Probe point 3px ahead of the slime and 2px beneath the ground surface
    final probeX = direction > 0 ? (position.x + size.x + 2) : (position.x - 2);
    final probeY = position.y + size.y + 2;

    bool hasGroundAhead = false;
    for (final block in game.solidBlocks) {
      final blockRect = Rect.fromLTWH(
        block.position.x,
        block.position.y,
        block.size.x,
        block.size.y,
      );

      if (blockRect.contains(Offset(probeX, probeY))) {
        hasGroundAhead = true;
        break;
      }
    }

    if (!hasGroundAhead) {
      turnAround();
    }
  }

  /// Clamps slime within valid horizontal cave walls.
  void _checkLevelBounds() {
    if (direction < 0 && position.x <= 16) {
      position.x = 16;
      turnAround();
    } else if (direction > 0 && position.x + size.x >= 240) {
      position.x = 240 - size.x;
      turnAround();
    }
  }

  /// Reverses the horizontal movement direction and sprite facing orientation.
  void turnAround() {
    direction = -direction;
    _updateFacingDirection();
  }

  void _updateFacingDirection() {
    if (direction > 0 && !isFacingRight) {
      flipHorizontallyAroundCenter();
      isFacingRight = true;
    } else if (direction < 0 && isFacingRight) {
      flipHorizontallyAroundCenter();
      isFacingRight = false;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (isDead) return;

    // Turn around when hitting a solid wall block on the side
    if (other is SolidBlock) {
      // Check if collision is horizontal
      if (intersectionPoints.isNotEmpty) {
        final contactPoint = intersectionPoints.first;
        if (contactPoint.y < position.y + size.y - 4) {
          turnAround();
        }
      }
      return;
    }

    // Hazard contact with KnightPlayer
    final knight = other is KnightPlayer
        ? other
        : (other.parent is KnightPlayer ? other.parent as KnightPlayer : null);

    if (knight != null) {
      if (knight.isSpeedBoostActive) {
        // Potion power-up eliminates the slime on contact
        die();
      } else {
        // Calculate knockback direction away from slime center
        final knockbackX = knight.position.x >= position.x ? 1.0 : -1.0;
        knight.takeDamage(1, Vector2(knockbackX, -1.0).normalized());
      }
    }
  }

  /// Destroys the slime with a squashing animation and awards bounty score.
  void die() {
    if (isDead) return;
    isDead = true;

    // Play hit sound effect
    AudioController.instance.playHit();

    // Award defeat bounty score
    game.scoreNotifier.value += 100;

    // Play squash and fade-out animation
    add(
      ScaleEffect.to(
        Vector2(1.3, 0.2),
        EffectController(duration: 0.18, curve: Curves.easeOut),
      ),
    );
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.18),
        onComplete: removeFromParent,
      ),
    );
  }

  /// Resets the Slime to starting position.
  void reset() {
    position = _spawnPosition.clone();
    direction = initialDirection;
    isDead = false;
    if (direction > 0 && !isFacingRight) {
      flipHorizontallyAroundCenter();
      isFacingRight = true;
    } else if (direction < 0 && isFacingRight) {
      flipHorizontallyAroundCenter();
      isFacingRight = false;
    }
  }
}
