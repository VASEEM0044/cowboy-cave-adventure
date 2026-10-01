import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/audio/audio_controller.dart';
import '../cowboy_cave_game.dart';
import 'combat/magic_projectile.dart';

/// Animation states for the playable Knight character.
enum PlayerState {
  idle,
  run,
  jump,
}

/// The playable Knight character component for Cowboy Cave Adventure.
///
/// Features:
/// - Pure 2D platformer jump-and-run physics (gravity, jump impulse, terminal velocity).
/// - Multi-touch mobile input (startMovingLeft, startMovingRight, jump, shoot)
///   alongside hardware keyboard controls.
/// - Speed boost power-up buff from Green Potion.
/// - Hazard damage reception, directional knockback, and invulnerability flickering.
/// - Sprite animation group from `assets/knight.png`.
/// - Separated axis collision resolution against [SolidBlock] components.
class KnightPlayer extends SpriteAnimationGroupComponent<PlayerState>
    with KeyboardHandler, CollisionCallbacks, HasGameReference<CowboyCaveGame> {
  KnightPlayer({
    required Vector2 spawnPosition,
  })  : _spawnPosition = spawnPosition.clone(),
        super(
          position: spawnPosition,
          size: Vector2(32, 32),
          anchor: Anchor.topLeft,
        );

  final Vector2 _spawnPosition;

  // Physics constants
  static const double moveSpeed = 90.0;
  static const double gravity = 520.0;
  static const double jumpSpeed = 195.0;
  static const double terminalVelocity = 280.0;

  // Hitbox geometry inside 32x32 frame
  static final Vector2 hitboxOffset = Vector2(9, 12);
  static final Vector2 hitboxSize = Vector2(14, 20);

  // Runtime physics state
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool jumpRequested = false;
  bool isFacingRight = true;

  // Life & Hazard states
  bool isDead = false;
  double _invulnerabilityTimer = 0.0;
  bool get isInvulnerable => _invulnerabilityTimer > 0;

  // Power-up state (Green Potion speed buff)
  double _speedMultiplier = 1.0;
  double _speedBoostTimer = 0.0;
  bool get isSpeedBoostActive => _speedBoostTimer > 0;

  // Combat: Magic Projectile shooting
  /// 1.0 = facing right, -1.0 = facing left. Updated on horizontal movement.
  double facingDirection = 1.0;
  double _shootCooldownTimer = 0.0;
  static const double shootCooldown = 0.28;

  static final Paint _speedAuraPaint = Paint()
    ..color = const Color(0x6600E676)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

  // Input states
  bool _touchMoveLeft = false;
  bool _touchMoveRight = false;
  int _keyboardHorizontalInput = 0;

  /// Effective combined horizontal input (-1, 0, or 1) from touch and keyboard.
  int get horizontalInput {
    int touch = 0;
    if (_touchMoveLeft) touch -= 1;
    if (_touchMoveRight) touch += 1;
    final total = touch + _keyboardHorizontalInput;
    return total.clamp(-1, 1);
  }

  late final RectangleHitbox bodyHitbox;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Load animations from knight.png (32x32 grid)
    final image = await game.images.load('knight.png');
    final spriteSheet = SpriteSheet(
      image: image,
      srcSize: Vector2(32, 32),
    );

    // Idle animation: Row 0 (4 frames)
    final idleAnimation = spriteSheet.createAnimation(
      row: 0,
      stepTime: 0.15,
      from: 0,
      to: 4,
    );

    // Run animation: Row 2 (8 frames)
    final runAnimation = spriteSheet.createAnimation(
      row: 2,
      stepTime: 0.08,
      from: 0,
      to: 8,
    );

    // Jump / In-air animation: Row 5 (4 frames)
    final jumpAnimation = spriteSheet.createAnimation(
      row: 5,
      stepTime: 0.1,
      from: 0,
      to: 4,
    );

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
    };

    current = PlayerState.idle;

    // 2. Attach active hitbox aligned with knight body
    bodyHitbox = RectangleHitbox(
      position: hitboxOffset,
      size: hitboxSize,
      collisionType: CollisionType.active,
    );
    add(bodyHitbox);
  }

  // --- Hazard Damage & Invulnerability ---

  /// Handles damage from hazard collisions (e.g. SlimeEnemy).
  void takeDamage(int amount, Vector2 knockbackDirection) {
    if (isInvulnerable || isDead) return;

    final currentLives = game.livesNotifier.value;
    final newLives = (currentLives - amount).clamp(0, 3);
    game.livesNotifier.value = newLives;

    if (newLives <= 0) {
      isDead = true;
      velocity = Vector2.zero();
      AudioController.instance.playGameOver();
      return;
    }

    AudioController.instance.playHit();

    // Apply knockback impulse
    velocity.x = knockbackDirection.x * 130.0;
    velocity.y = -120.0;
    isOnGround = false;

    // Activate 1.5-second invulnerability window
    _invulnerabilityTimer = 1.5;
  }

  // --- Power-Up Buff Methods ---

  /// Grants a temporary speed multiplier for the specified duration.
  void applySpeedBoost({double durationSeconds = 8.0, double multiplier = 1.45}) {
    _speedBoostTimer = durationSeconds;
    _speedMultiplier = multiplier;
  }

  // --- Touch Controls Hooks ---

  void startMovingLeft() {
    _touchMoveLeft = true;
  }

  void stopMovingLeft() {
    _touchMoveLeft = false;
  }

  void startMovingRight() {
    _touchMoveRight = true;
  }

  void stopMovingRight() {
    _touchMoveRight = false;
  }

  void jump() {
    if (!isDead) jumpRequested = true;
  }

  void shoot() {
    if (isDead || _shootCooldownTimer > 0) return;

    _shootCooldownTimer = shootCooldown;

    // Play shoot sound effect
    AudioController.instance.playShoot();

    // Spawn projectile offset ahead of player in the facing direction
    final spawnPos = position + Vector2(facingDirection * 12, -8);

    final projectile = MagicProjectile(
      startPosition: spawnPos,
      direction: facingDirection,
    );

    game.world.add(projectile);
  }

  // --- Keyboard Controls Handling ---

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (isDead) return true;

    _keyboardHorizontalInput = 0;
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      _keyboardHorizontalInput -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      _keyboardHorizontalInput += 1;
    }

    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.keyW ||
            event.logicalKey == LogicalKeyboardKey.arrowUp)) {
      jumpRequested = true;
    }

    // Shoot on Z or X key press
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.keyZ ||
            event.logicalKey == LogicalKeyboardKey.keyX)) {
      shoot();
    }

    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDead) return;

    // 0. Update Invulnerability Timer
    if (_invulnerabilityTimer > 0) {
      _invulnerabilityTimer -= dt;
      if (_invulnerabilityTimer <= 0) {
        _invulnerabilityTimer = 0;
      }
    }

    // 0.1 Update Speed Boost Buff Timer
    if (_speedBoostTimer > 0) {
      _speedBoostTimer -= dt;
      if (_speedBoostTimer <= 0) {
        _speedBoostTimer = 0;
        _speedMultiplier = 1.0;
      }
    }

    // 0.2 Update Shoot Cooldown Timer
    if (_shootCooldownTimer > 0) {
      _shootCooldownTimer -= dt;
      if (_shootCooldownTimer <= 0) {
        _shootCooldownTimer = 0;
      }
    }

    // 1. Horizontal Velocity with speed multiplier applied
    velocity.x = horizontalInput * (moveSpeed * _speedMultiplier);

    // 2. Jump Impulse
    if (jumpRequested) {
      jumpRequested = false;
      if (isOnGround) {
        velocity.y = -jumpSpeed;
        isOnGround = false;
        AudioController.instance.playJump();
      }
    }

    // 3. Gravity Acceleration
    velocity.y += gravity * dt;
    if (velocity.y > terminalVelocity) {
      velocity.y = terminalVelocity;
    }

    // 4. X-Axis Movement & Collision Separation
    position.x += velocity.x * dt;
    if (isMounted) {
      _resolveHorizontalCollisions();
    }

    // 5. Y-Axis Movement & Collision Separation
    position.y += velocity.y * dt;
    if (isMounted) {
      _resolveVerticalCollisions();
    }

    // 6. Level Boundary Clamping
    _clampToLevelBounds();

    // 7. Sprite Direction Flipping & Animation States
    _updateSpriteDirectionAndAnimation();
  }

  @override
  void render(Canvas canvas) {
    // Flickering / blinking opacity during invulnerability frames
    if (isInvulnerable) {
      final isBlinkHidden = ((_invulnerabilityTimer * 12).floor() % 2) == 0;
      if (isBlinkHidden) return;
    }

    // Draw green speed boost aura under feet when active
    if (isSpeedBoostActive) {
      canvas.drawCircle(const Offset(16, 26), 9, _speedAuraPaint);
    }

    super.render(canvas);
  }

  void _resolveHorizontalCollisions() {
    final playerRect = Rect.fromLTWH(
      position.x + hitboxOffset.x,
      position.y + hitboxOffset.y,
      hitboxSize.x,
      hitboxSize.y,
    );

    for (final block in game.solidBlocks) {
      final blockRect = Rect.fromLTWH(
        block.position.x,
        block.position.y,
        block.size.x,
        block.size.y,
      );

      if (playerRect.overlaps(blockRect)) {
        if (velocity.x > 0) {
          // Moving right -> snap to left edge of solid block
          position.x = block.position.x - hitboxOffset.x - hitboxSize.x;
          velocity.x = 0;
        } else if (velocity.x < 0) {
          // Moving left -> snap to right edge of solid block
          position.x = block.position.x + block.size.x - hitboxOffset.x;
          velocity.x = 0;
        }
      }
    }
  }

  void _resolveVerticalCollisions() {
    bool grounded = false;

    final playerRect = Rect.fromLTWH(
      position.x + hitboxOffset.x,
      position.y + hitboxOffset.y,
      hitboxSize.x,
      hitboxSize.y,
    );

    for (final block in game.solidBlocks) {
      final blockRect = Rect.fromLTWH(
        block.position.x,
        block.position.y,
        block.size.x,
        block.size.y,
      );

      if (playerRect.overlaps(blockRect)) {
        if (velocity.y > 0) {
          // Falling downward -> land on top of solid block
          position.y = block.position.y - hitboxOffset.y - hitboxSize.y;
          velocity.y = 0;
          grounded = true;
        } else if (velocity.y < 0) {
          // Jumping upward -> head bonk against bottom of solid block
          position.y = block.position.y + block.size.y - hitboxOffset.y;
          velocity.y = 0;
        }
      }
    }

    isOnGround = grounded;
  }

  void _clampToLevelBounds() {
    // Left boundary
    if (position.x < -hitboxOffset.x) {
      position.x = -hitboxOffset.x;
      velocity.x = 0;
    }
    // Right boundary (256px)
    if (position.x + hitboxOffset.x + hitboxSize.x > 256) {
      position.x = 256 - hitboxOffset.x - hitboxSize.x;
      velocity.x = 0;
    }
    // Bottom abyss fallback respawn
    if (position.y > 270) {
      respawn();
    }
  }

  void _updateSpriteDirectionAndAnimation() {
    // Direction flip and facingDirection update for projectile aim
    if (horizontalInput < 0 && isFacingRight) {
      flipHorizontallyAroundCenter();
      isFacingRight = false;
      facingDirection = -1.0;
    } else if (horizontalInput > 0 && !isFacingRight) {
      flipHorizontallyAroundCenter();
      isFacingRight = true;
      facingDirection = 1.0;
    }

    // Animation state machine (only update current if animations map has loaded)
    if (animations != null) {
      if (!isOnGround) {
        current = PlayerState.jump;
      } else if (horizontalInput != 0) {
        current = PlayerState.run;
      } else {
        current = PlayerState.idle;
      }
    }
  }

  /// Resets the Knight to the starting spawn position and restores health state.
  void respawn() {
    position = _spawnPosition.clone();
    velocity = Vector2.zero();
    isOnGround = false;
    isDead = false;
    _invulnerabilityTimer = 0;
    _touchMoveLeft = false;
    _touchMoveRight = false;
    _keyboardHorizontalInput = 0;
    _speedBoostTimer = 0;
    _speedMultiplier = 1.0;
    _shootCooldownTimer = 0;
    facingDirection = 1.0;
    if (!isFacingRight) {
      flipHorizontallyAroundCenter();
      isFacingRight = true;
    }
    if (animations != null) {
      current = PlayerState.idle;
    }
  }
}
