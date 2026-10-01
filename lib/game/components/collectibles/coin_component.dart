import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/animation.dart';
import '../../../core/audio/audio_controller.dart';
import '../../cowboy_cave_game.dart';
import '../knight_player.dart';

/// Animated collectible Coin component.
///
/// Features:
/// - 12-frame rotating animation strip loaded from `assets/coin.png` (16x16).
/// - Passive circular hitbox.
/// - Grants +10 points and increments coin counter upon Knight collision.
/// - Floating pop fade-out effect on pickup.
class CoinComponent extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<CowboyCaveGame> {
  CoinComponent({
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

    // Load 12-frame spinning animation strip from coin.png
    final image = await game.images.load('coin.png');
    final spriteSheet = SpriteSheet(
      image: image,
      srcSize: Vector2(16, 16),
    );

    animation = spriteSheet.createAnimation(
      row: 0,
      stepTime: 0.08,
      from: 0,
      to: 12,
    );

    // Attach passive circular hitbox
    add(
      CircleHitbox(
        radius: 6,
        position: Vector2(2, 2),
        collisionType: CollisionType.passive,
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

  /// Triggers coin collection logic and cleanup animation.
  void collect() {
    if (_isCollected) return;
    _isCollected = true;

    // Play coin pickup sound
    AudioController.instance.playCoin();

    // 1. Update Game Score & Coin counter
    game.scoreNotifier.value += 10;
    game.coinsNotifier.value += 1;

    // 2. Float up and fade out before removing
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
