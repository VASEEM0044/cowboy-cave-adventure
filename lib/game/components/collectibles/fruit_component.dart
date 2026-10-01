import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import '../../../core/audio/audio_controller.dart';
import '../../cowboy_cave_game.dart';
import '../knight_player.dart';

/// Bonus Fruit collectible component.
///
/// Features:
/// - Sprite loaded from `assets/fruit.png` (16x16).
/// - Gentle floating bob effect.
/// - Grants +50 points and restores 1 heart life on pickup.
class FruitComponent extends SpriteComponent
    with CollisionCallbacks, HasGameReference<CowboyCaveGame> {
  FruitComponent({
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

    // Load fruit sprite (first 16x16 frame of fruit.png)
    final image = await game.images.load('fruit.png');
    sprite = Sprite(
      image,
      srcPosition: Vector2.zero(),
      srcSize: Vector2(16, 16),
    );

    // Attach passive hitbox
    add(
      RectangleHitbox(
        size: Vector2(12, 12),
        position: Vector2(2, 2),
        collisionType: CollisionType.passive,
      ),
    );

    // Gentle floating bob animation
    add(
      MoveByEffect(
        Vector2(0, -3),
        EffectController(
          duration: 0.8,
          reverseDuration: 0.8,
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

    if (other is KnightPlayer || other.parent is KnightPlayer) {
      collect();
    }
  }

  /// Triggers fruit collection logic and bonus life reward.
  void collect() {
    if (_isCollected) return;
    _isCollected = true;

    // Play coin/reward sound
    AudioController.instance.playCoin();

    // 1. High-value score reward
    game.scoreNotifier.value += 50;

    // 2. Restore 1 life if below max
    if (game.livesNotifier.value < 3) {
      game.livesNotifier.value += 1;
    }

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
