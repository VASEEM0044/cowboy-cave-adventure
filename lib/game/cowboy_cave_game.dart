import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../core/audio/audio_controller.dart';
import '../core/constants/app_constants.dart';
import 'components/collectibles/coin_component.dart';
import 'components/collectibles/fruit_component.dart';
import 'components/collectibles/potion_component.dart';
import 'components/enemies/slime_enemy.dart';
import 'components/exit_gate_component.dart';
import 'components/knight_player.dart';
import 'components/ldtk_map_component.dart';
import 'components/solid_block.dart';
import 'loaders/ldtk_level_loader.dart';

/// Single-screen arcade Flame Game for Cowboy Cave Adventure.
///
/// Features:
/// - Fixed 256 x 256 virtual resolution matching the LDtk tilemap canvas.
/// - HasCollisionDetection mixin configured for solid geometry & collectibles.
/// - HasKeyboardHandlerComponents mixin for responsive desktop & simulator controls.
/// - Reactive state notifiers for lives, score, coins, and pause state.
/// - Spawns static [SolidBlock] collision boundaries from LDtk IntGrid.
/// - Spawns playable [KnightPlayer] at LDtk PlayerSpawn coordinates.
/// - Spawns animated [CoinComponent], [FruitComponent], and [PotionComponent] collectibles.
/// - Spawns [ExitGateComponent] win condition trigger.
class CowboyCaveGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  CowboyCaveGame({
    this.levelNumber = 1,
    bool enableDebugMode = false,
  }) : super(
          camera: CameraComponent.withFixedResolution(
            width: AppConstants.virtualWidth,
            height: AppConstants.virtualHeight,
          ),
        ) {
    debugMode = enableDebugMode;
  }

  /// Active level number selected by player.
  final int levelNumber;

  /// Parsed LDtk level data for the active level.
  late final LdtkLevelData levelData;

  /// All active solid block collision components.
  final List<SolidBlock> solidBlocks = [];

  /// Active spawned collectible components.
  final List<Component> collectibles = [];

  /// Active spawned enemy components.
  final List<SlimeEnemy> enemies = [];

  /// Total number of coins placed in the level.
  int totalCoins = 0;

  /// The active playable Knight character.
  late final KnightPlayer player;

  /// The exit gate component.
  ExitGateComponent? exitGate;

  // Live game state notifiers for HUD and UI overlays
  final ValueNotifier<int> livesNotifier = ValueNotifier<int>(3);
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> isPausedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isLevelCompleteNotifier = ValueNotifier<bool>(false);

  @override
  Color backgroundColor() => AppConstants.colorBackground;

  @override
  FutureOr<void> onLoad() async {
    // Set Flame image asset prefix directly to 'assets/'
    images.prefix = 'assets/';

    await super.onLoad();

    // Start background music loop
    AudioController.instance.playBgm();

    // The camera's viewfinder anchor is anchored top-left for 256x256 pixel coordinates.
    camera.viewfinder.anchor = Anchor.topLeft;

    // Load LDtk level data from assets/backy.ldtk
    levelData = await LdtkLevelLoader.loadLevel(
      'assets/backy.ldtk',
      levelId: 'Level_0',
    );

    // 1. Add static visual map component to the world
    await world.add(LdtkMapComponent(levelData));

    // 2. Add static solid collision barriers to the world
    for (final box in levelData.collisionBoxes) {
      final solidBlock = SolidBlock(
        position: Vector2(box.x, box.y),
        size: Vector2(box.width, box.height),
      );
      solidBlocks.add(solidBlock);
      await world.add(solidBlock);
    }

    // 3. Spawn Knight player at parsed PlayerSpawn coordinates
    final spawn = levelData.playerSpawn;
    final spawnPos = spawn != null
        ? Vector2(spawn.x, spawn.y - (32 - spawn.height))
        : Vector2(16, 208);

    player = KnightPlayer(spawnPosition: spawnPos);
    await world.add(player);

    // 4. Spawn Collectibles (Coins, Fruit, Potion)
    await _spawnCollectibles();

    // 5. Spawn Enemies (Slimes)
    await _spawnEnemies();

    // 6. Spawn Exit Gate
    await _spawnExitGate();
  }

  /// Spawns all level collectibles into the world.
  Future<void> _spawnCollectibles() async {
    // Clear any existing collectibles
    for (final c in collectibles) {
      if (c.isMounted) c.removeFromParent();
    }
    collectibles.clear();

    totalCoins = 0;

    try {
      // Spawn Coins and Fruit from LDtk entities
      for (final entity in levelData.entities) {
        if (entity.identifier == 'Coin') {
          totalCoins++;
          final coin = CoinComponent(position: Vector2(entity.x, entity.y));
          collectibles.add(coin);
          await world.add(coin);
        } else if (entity.identifier == 'Fruit') {
          final fruit = FruitComponent(position: Vector2(entity.x, entity.y));
          collectibles.add(fruit);
          await world.add(fruit);
        }
      }

      // Spawn Green Potion on top-left shelf room (48, 16)
      final potion = PotionComponent(position: Vector2(48, 16));
      collectibles.add(potion);
      await world.add(potion);
    } catch (_) {
      // levelData not yet loaded in unit test context
    }
  }

  /// Spawns all level enemies into the world.
  Future<void> _spawnEnemies() async {
    // Clear any existing enemies
    for (final e in enemies) {
      if (e.isMounted) e.removeFromParent();
    }
    enemies.clear();

    try {
      // Spawn Slime enemies from LDtk entities
      // In LDtk, Slime entities are placed with grid size 16 at y=224, feet on ground y=240.
      // For 24x24 sprite, y position = 224 - (24 - 16) = 216.
      for (final entity in levelData.entities) {
        if (entity.identifier == 'Slime') {
          final slimeY = entity.y - (24 - entity.height);
          final slime = SlimeEnemy(
            spawnPosition: Vector2(entity.x, slimeY.toDouble()),
          );
          enemies.add(slime);
          await world.add(slime);
        }
      }
    } catch (_) {
      // levelData not yet loaded in unit test context
    }
  }

  /// Spawns the exit gate into the world.
  Future<void> _spawnExitGate() async {
    if (exitGate != null && exitGate!.isMounted) {
      exitGate!.removeFromParent();
    }

    final gateEntity = levelData.exitGate;
    final gatePos = gateEntity != null
        ? Vector2(gateEntity.x, gateEntity.y)
        : Vector2(224, 224);

    exitGate = ExitGateComponent(
      position: gatePos,
      size: Vector2(16, 16),
    );
    await world.add(exitGate!);
  }

  /// Pauses the game loop and updates the pause notifier.
  void pauseGame() {
    pauseEngine();
    isPausedNotifier.value = true;
    AudioController.instance.pauseBgm();
  }

  /// Resumes the game loop and updates the pause notifier.
  void resumeGame() {
    resumeEngine();
    isPausedNotifier.value = false;
    AudioController.instance.resumeBgm();
  }

  /// Freezes gameplay and opens the level complete victory dialog.
  void completeLevel() {
    pauseEngine();
    isLevelCompleteNotifier.value = true;
  }

  /// Resets player position, respawns collectibles, resets enemies, and restores health state.
  void restartLevel() {
    isLevelCompleteNotifier.value = false;
    livesNotifier.value = 3;
    player.respawn();
    coinsNotifier.value = 0;
    exitGate?.reset();
    _spawnCollectibles();
    _spawnEnemies();
    resumeGame();
  }

  /// Toggles debug hitbox wireframe rendering on or off.
  void toggleHitboxDebug() {
    debugMode = !debugMode;
  }

  @override
  void onRemove() {
    livesNotifier.dispose();
    scoreNotifier.dispose();
    coinsNotifier.dispose();
    isPausedNotifier.dispose();
    isLevelCompleteNotifier.dispose();
    super.onRemove();
  }
}
