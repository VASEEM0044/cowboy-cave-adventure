import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import '../../../core/audio/audio_controller.dart';
import '../../cowboy_cave_game.dart';
import '../knight_player.dart';

/// Green Potion Bottle power-up component.
///
/// Features:
/// - Cropped from `assets/world_tileset.png` at (0, 112) [16x16].
/// - Positioned on the top-left shelf room.
/// - Grants a temporary 1.45x speed boost to KnightPlayer for 8 seconds.
class PotionComponent extends SpriteComponent
    with CollisionCallbacks, HasGameReference<CowboyCaveGame> {
  PotionComponent({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(16, 16),
          anchor: Anchor.topLeft,
        );

  bool _isCollected = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Crop green bottle tile from world_tileset.png (src: 0, 112, 16x16)
    final image = await game.images.load('world_tileset.png');
    sprite = Sprite(
      image,
      srcPosition: Vector2(0, 112),
      srcSize: Vector2(16, 16),
    );

    // Attach passive hitbox
    add(
      RectangleHitbox(
        size: Vector2(12, 14),
        position: Vector2(2, 1),
        collisionType: CollisionType.passive,
      ),
    );

    // Subtle breathing pulse
    add(
      ScaleEffect.by(
        Vector2.all(1.1),
        EffectController(
          duration: 0.6,
          reverseDuration: 0.6,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (_isCollected) return;

    final knight = other is KnightPlayer
        ? other
        : (other.parent is KnightPlayer ? other.parent as KnightPlayer : null);

    if (knight != null) {
      collect(knight);
    }
  }

  /// Triggers potion collection and grants speed buff.
  void collect(KnightPlayer knight) {
    if (_isCollected) return;
    _isCollected = true;

    // Play pickup sound
    AudioController.instance.playCoin();

    // 1. Grant 1.45x movement speed buff for 8 seconds
    knight.applySpeedBoost(durationSeconds: 8.0, multiplier: 1.45);

    // 2. Bonus score
    game.scoreNotifier.value += 25;

    // 3. Float up and fade out before removing
    add(
      MoveByEffect(
        Vector2(0, -12),
        EffectController(duration: 0.25, curve: Curves.easeOut),
      ),
    );
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.25),
        onComplete: removeFromParent,
      ),
    );
  }
}
