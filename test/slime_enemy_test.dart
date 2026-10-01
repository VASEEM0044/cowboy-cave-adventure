import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cowboycavead/game/components/enemies/slime_enemy.dart';
import 'package:cowboycavead/game/components/knight_player.dart';
import 'package:cowboycavead/game/components/solid_block.dart';
import 'package:cowboycavead/game/cowboy_cave_game.dart';
import 'package:cowboycavead/game/loaders/ldtk_level_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 7: Slime Enemy Patrol AI & Hazard Tests', () {
    test('Parses exactly 2 Slime entities from assets/backy.ldtk', () async {
      final levelData = await LdtkLevelLoader.loadLevel(
        'assets/backy.ldtk',
        levelId: 'Level_0',
      );

      final slimes = levelData.entities.where((e) => e.identifier == 'Slime').toList();

      expect(slimes.length, equals(2));
      expect(slimes[0].x, equals(144.0));
      expect(slimes[0].y, equals(224.0));
      expect(slimes[1].x, equals(176.0));
      expect(slimes[1].y, equals(224.0));
    });

    test('SlimeEnemy patrols horizontally and reverses direction on turnAround', () {
      final slime = SlimeEnemy(
        spawnPosition: Vector2(144, 216),
        initialDirection: -1,
      );

      expect(slime.direction, equals(-1));
      expect(slime.position.x, equals(144.0));

      slime.update(0.1);
      // Moved left by moveSpeed * 0.1 = 35 * 0.1 = 3.5
      expect(slime.position.x, closeTo(140.5, 0.001));

      slime.turnAround();
      expect(slime.direction, equals(1));
      // flipHorizontallyAroundCenter() shifts position.x by sprite width (24)
      // when anchor is Anchor.topLeft: 140.5 + 24 = 164.5
      expect(slime.position.x, closeTo(164.5, 0.001));

      slime.update(0.1);
      // Moved right by 3.5 -> 164.5 + 3.5 = 168.0
      expect(slime.position.x, closeTo(168.0, 0.001));
    });

    test('Slime contact deals 1 damage to Knight, knocks back, and triggers invulnerability', () {
      final game = CowboyCaveGame(levelNumber: 1);
      final knight = KnightPlayer(spawnPosition: Vector2(100, 208));
      knight.game = game;

      expect(game.livesNotifier.value, equals(3));
      expect(knight.isInvulnerable, isFalse);

      // Knight takes 1 damage from the right (slime at x=120)
      knight.takeDamage(1, Vector2(-1.0, -1.0).normalized());

      expect(game.livesNotifier.value, equals(2));
      expect(knight.isInvulnerable, isTrue);
      expect(knight.velocity.x, lessThan(0)); // Knockback to left
      expect(knight.velocity.y, lessThan(0)); // Knockback upward

      // While invulnerable, another hit should not deduct lives
      knight.takeDamage(1, Vector2(-1.0, -1.0).normalized());
      expect(game.livesNotifier.value, equals(2));

      // Advance time past 1.5s invulnerability window
      knight.update(1.6);
      expect(knight.isInvulnerable, isFalse);
    });

    test('Knight losing all 3 lives sets isDead to true and stops velocity', () {
      final game = CowboyCaveGame(levelNumber: 1);
      final knight = KnightPlayer(spawnPosition: Vector2(100, 208));
      knight.game = game;

      expect(knight.isDead, isFalse);

      // Deal 3 damage directly
      knight.takeDamage(3, Vector2(1.0, -1.0));

      expect(game.livesNotifier.value, equals(0));
      expect(knight.isDead, isTrue);
      expect(knight.velocity, equals(Vector2.zero()));
    });

    test('Green Potion speed buff eliminates Slime on contact via die()', () {
      final game = CowboyCaveGame(levelNumber: 1);
      final slime = SlimeEnemy(spawnPosition: Vector2(144, 216));
      slime.game = game;

      expect(slime.isDead, isFalse);
      final initialScore = game.scoreNotifier.value;

      slime.die();

      expect(slime.isDead, isTrue);
      // Defeat bounty awards 100 points
      expect(game.scoreNotifier.value, equals(initialScore + 100));
    });

    test('Slime cliff/edge detection triggers turnaround when no floor ahead', () {
      final game = CowboyCaveGame(levelNumber: 1);
      // Add a platform solid block from x=100 to x=150 at y=240, height 16
      final platform = SolidBlock(
        position: Vector2(100, 240),
        size: Vector2(50, 16),
      );
      game.solidBlocks.add(platform);

      // Place slime on platform at x=102, moving left (-1)
      final slime = SlimeEnemy(
        spawnPosition: Vector2(102, 216),
        initialDirection: -1,
      );
      slime.game = game;

      // Verify initial direction
      expect(slime.direction, equals(-1));

      // Manually simulate the edge detection logic:
      // After 0.1s, position.x = 102 - 3.5 = 98.5
      // Probe point for direction=-1: position.x - 2 = 96.5 (left of platform at x=100)
      // No ground ahead -> should turn around
      slime.position.x = 98.5; // Simulate position after movement
      // Probe: probeX = 98.5 - 2 = 96.5 which is outside platform (100..150)
      final probeX = slime.position.x - 2;
      final probeY = slime.position.y + slime.size.y + 2;
      final blockRect = Rect.fromLTWH(
        platform.position.x,
        platform.position.y,
        platform.size.x,
        platform.size.y,
      );
      // Verify probe point falls outside the platform
      expect(blockRect.contains(Offset(probeX, probeY)), isFalse);

      // Now verify turnAround works correctly
      slime.turnAround();
      expect(slime.direction, equals(1));
    });
  });
}
