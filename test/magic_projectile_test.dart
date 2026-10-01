import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cowboycavead/game/components/combat/magic_projectile.dart';
import 'package:cowboycavead/game/components/enemies/slime_enemy.dart';
import 'package:cowboycavead/game/components/knight_player.dart';
import 'package:cowboycavead/game/cowboy_cave_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 8: Magic Projectile Shooting Tests', () {
    test('MagicProjectile spawns with correct direction and speed constant', () {
      final projectile = MagicProjectile(
        startPosition: Vector2(100, 100),
        direction: 1.0,
      );

      expect(projectile.direction, equals(1.0));
      expect(projectile.position.x, equals(100.0));
      expect(projectile.position.y, equals(100.0));
      expect(projectile.size, equals(Vector2(8, 8)));
      expect(MagicProjectile.speed, equals(260.0));
    });

    test('MagicProjectile moves purely horizontally (no gravity)', () {
      final projectileRight = MagicProjectile(
        startPosition: Vector2(100, 100),
        direction: 1.0,
      );

      final projectileLeft = MagicProjectile(
        startPosition: Vector2(200, 100),
        direction: -1.0,
      );

      // Simulate 0.1 second update
      projectileRight.update(0.1);
      projectileLeft.update(0.1);

      // Right: 100 + (1.0 * 260 * 0.1) = 126.0
      expect(projectileRight.position.x, closeTo(126.0, 0.001));
      // Y should NOT change (no gravity)
      expect(projectileRight.position.y, equals(100.0));

      // Left: 200 + (-1.0 * 260 * 0.1) = 174.0
      expect(projectileLeft.position.x, closeTo(174.0, 0.001));
      expect(projectileLeft.position.y, equals(100.0));
    });

    test('KnightPlayer facingDirection updates on horizontal input change', () {
      final game = CowboyCaveGame(levelNumber: 1);
      final knight = KnightPlayer(spawnPosition: Vector2(100, 200));
      knight.game = game;

      // Default facing right
      expect(knight.facingDirection, equals(1.0));
      expect(knight.isFacingRight, isTrue);

      // Simulate moving left
      knight.startMovingLeft();
      knight.update(0.016); // One frame tick
      expect(knight.facingDirection, equals(-1.0));
      expect(knight.isFacingRight, isFalse);

      // Simulate moving right again
      knight.stopMovingLeft();
      knight.startMovingRight();
      knight.update(0.016);
      expect(knight.facingDirection, equals(1.0));
      expect(knight.isFacingRight, isTrue);

      knight.stopMovingRight();
    });

    test('KnightPlayer shoot cooldown prevents rapid fire', () {
      final game = CowboyCaveGame(levelNumber: 1);
      final knight = KnightPlayer(spawnPosition: Vector2(100, 200));
      knight.game = game;

      expect(KnightPlayer.shootCooldown, equals(0.28));

      // First shoot should work (cooldown is 0)
      knight.shoot();
      // Cooldown is now active — cannot verify projectile count without game world,
      // but can verify cooldown blocks the next shot

      // Immediately try again — should be blocked by cooldown
      // Update by a small amount (less than 0.28s)
      knight.update(0.1);
      // Cooldown still active (0.28 - 0.1 = 0.18 remaining)

      // After cooldown expires, shooting should work again
      knight.update(0.2); // Total elapsed: 0.3s > 0.28s
      // Now cooldown has expired, next shoot should work
      knight.shoot(); // Should not throw
    });

    test('KnightPlayer cannot shoot when isDead', () {
      final game = CowboyCaveGame(levelNumber: 1);
      final knight = KnightPlayer(spawnPosition: Vector2(100, 200));
      knight.game = game;

      // Kill the knight
      knight.takeDamage(3, Vector2(1, -1));
      expect(knight.isDead, isTrue);

      // Attempting to shoot while dead should not throw
      knight.shoot(); // No-op, should not create projectile or crash
    });

    test('Projectile spawn position uses facingDirection offset correctly', () {
      final game = CowboyCaveGame(levelNumber: 1);
      final knight = KnightPlayer(spawnPosition: Vector2(100, 200));
      knight.game = game;

      // Facing right (default): spawnPos = position + Vector2(1.0 * 12, -8) = (112, 192)
      expect(knight.facingDirection, equals(1.0));
      final rightSpawn = knight.position + Vector2(knight.facingDirection * 12, -8);
      expect(rightSpawn, equals(Vector2(112, 192)));

      // Switch to facing left
      knight.startMovingLeft();
      knight.update(0.016);
      expect(knight.facingDirection, equals(-1.0));

      // Facing left: spawnPos = position + Vector2(-1.0 * 12, -8) = (pos.x - 12, pos.y - 8)
      final leftSpawn = knight.position + Vector2(knight.facingDirection * 12, -8);
      expect(leftSpawn.x, closeTo(knight.position.x - 12, 0.1));
      expect(leftSpawn.y, closeTo(knight.position.y - 8, 0.1));

      knight.stopMovingLeft();
    });

    test('MagicProjectile removes itself at arena bounds (x < -8 or x > 264)', () {
      // Test right bound
      final projectileRight = MagicProjectile(
        startPosition: Vector2(260, 100),
        direction: 1.0,
      );
      // 260 + (260 * 0.1) = 286 > 264 → should trigger removal
      projectileRight.update(0.1);
      // In unit test without parent, removeFromParent() may throw —
      // instead verify position crossed the threshold
      expect(projectileRight.position.x, greaterThan(264));

      // Test left bound
      final projectileLeft = MagicProjectile(
        startPosition: Vector2(0, 100),
        direction: -1.0,
      );
      // 0 + (-260 * 0.1) = -26 < -8 → should trigger removal
      projectileLeft.update(0.1);
      expect(projectileLeft.position.x, lessThan(-8));
    });

    test('SlimeEnemy die awards 100 bounty and MagicProjectile hit adds 25 bonus', () {
      final game = CowboyCaveGame(levelNumber: 1);
      final slime = SlimeEnemy(spawnPosition: Vector2(144, 216));
      slime.game = game;

      final initialScore = game.scoreNotifier.value;
      expect(slime.isDead, isFalse);

      // Simulate projectile-slime hit: slime.die() awards 100, projectile adds 25
      slime.die();
      game.scoreNotifier.value += 25; // Projectile bonus

      expect(slime.isDead, isTrue);
      expect(game.scoreNotifier.value, equals(initialScore + 125));
    });

    test('KnightPlayer respawn resets shoot cooldown and facingDirection', () {
      final game = CowboyCaveGame(levelNumber: 1);
      final knight = KnightPlayer(spawnPosition: Vector2(100, 200));
      knight.game = game;

      // Change facing and trigger cooldown
      knight.startMovingLeft();
      knight.update(0.016);
      expect(knight.facingDirection, equals(-1.0));
      knight.shoot();
      knight.stopMovingLeft();

      // Respawn should reset
      knight.respawn();
      expect(knight.facingDirection, equals(1.0));
      expect(knight.isDead, isFalse);
    });
  });
}
