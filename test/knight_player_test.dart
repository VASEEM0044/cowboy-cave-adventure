import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cowboycavead/game/components/knight_player.dart';
import 'package:cowboycavead/game/loaders/ldtk_level_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 4: Knight Player & Platformer Physics Tests', () {
    test('Extracts PlayerSpawn entity from assets/backy.ldtk', () async {
      final levelData = await LdtkLevelLoader.loadLevel(
        'assets/backy.ldtk',
        levelId: 'Level_0',
      );

      final spawn = levelData.playerSpawn;
      expect(spawn, isNotNull);
      expect(spawn!.identifier, equals('PlayerSpawn'));
      expect(spawn.x, equals(0.0));
      expect(spawn.y, equals(224.0));
      expect(spawn.width, equals(16.0));
      expect(spawn.height, equals(16.0));
    });

    test('KnightPlayer initializes with correct default physics values', () {
      final player = KnightPlayer(spawnPosition: Vector2(16, 208));

      expect(player.velocity, equals(Vector2.zero()));
      expect(player.isOnGround, isFalse);
      expect(player.isFacingRight, isTrue);
      expect(KnightPlayer.moveSpeed, equals(90.0));
      expect(KnightPlayer.gravity, equals(520.0));
      expect(KnightPlayer.jumpSpeed, equals(195.0));
    });

    test('KnightPlayer jump requires isOnGround to be true', () {
      final player = KnightPlayer(spawnPosition: Vector2(16, 208));

      // 1. In-air: jump request should not apply velocity
      player.isOnGround = false;
      player.jumpRequested = true;
      player.update(0.016);

      expect(player.velocity.y, greaterThan(0)); // Gravity applied, no jump impulse

      // 2. Grounded: jump request applies jump impulse
      player.isOnGround = true;
      player.jumpRequested = true;
      player.update(0.016);

      expect(player.velocity.y, lessThan(0)); // Negative upward velocity applied
      expect(player.isOnGround, isFalse);
    });

    test('KnightPlayer horizontal velocity matches input direction', () {
      final player = KnightPlayer(spawnPosition: Vector2(50, 200));

      // Move Right
      player.startMovingRight();
      player.update(0.016);
      expect(player.velocity.x, equals(KnightPlayer.moveSpeed));

      // Move Left
      player.stopMovingRight();
      player.startMovingLeft();
      player.update(0.016);
      expect(player.velocity.x, equals(-KnightPlayer.moveSpeed));

      // Idle
      player.stopMovingLeft();
      player.update(0.016);
      expect(player.velocity.x, equals(0.0));
    });
  });
}
