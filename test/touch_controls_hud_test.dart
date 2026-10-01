import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cowboycavead/game/components/knight_player.dart';
import 'package:cowboycavead/game/cowboy_cave_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 5: Touch Controls & Game HUD Tests', () {
    test('KnightPlayer touch movement controls work properly', () {
      final player = KnightPlayer(spawnPosition: Vector2(50, 200));

      // Move Right via touch
      player.startMovingRight();
      player.update(0.016);
      expect(player.velocity.x, equals(KnightPlayer.moveSpeed));

      // Stop moving Right
      player.stopMovingRight();
      player.update(0.016);
      expect(player.velocity.x, equals(0.0));

      // Move Left via touch
      player.startMovingLeft();
      player.update(0.016);
      expect(player.velocity.x, equals(-KnightPlayer.moveSpeed));

      // Stop moving Left
      player.stopMovingLeft();
      player.update(0.016);
      expect(player.velocity.x, equals(0.0));
    });

    test('KnightPlayer simultaneous running and jumping (multi-touch)', () {
      final player = KnightPlayer(spawnPosition: Vector2(50, 200));
      player.isOnGround = true;

      // Hold Right
      player.startMovingRight();
      player.update(0.016);
      expect(player.velocity.x, equals(KnightPlayer.moveSpeed));

      // Tap Jump while still holding Right
      player.jump();
      player.update(0.016);

      // Both horizontal velocity and jump impulse must be active simultaneously!
      expect(player.velocity.x, equals(KnightPlayer.moveSpeed));
      expect(player.velocity.y, lessThan(0)); // Upward jump velocity
      expect(player.isOnGround, isFalse);
    });

    test('KnightPlayer shoot hook executes without exception', () {
      final game = CowboyCaveGame(levelNumber: 1);
      final player = KnightPlayer(spawnPosition: Vector2(50, 200));
      player.game = game;
      expect(() => player.shoot(), returnsNormally);
    });

    test('CowboyCaveGame state notifiers and pause controls function correctly', () {
      final game = CowboyCaveGame(levelNumber: 1);

      // Default state
      expect(game.livesNotifier.value, equals(3));
      expect(game.scoreNotifier.value, equals(0));
      expect(game.coinsNotifier.value, equals(0));
      expect(game.isPausedNotifier.value, isFalse);

      // Pause game
      game.pauseGame();
      expect(game.isPausedNotifier.value, isTrue);

      // Resume game
      game.resumeGame();
      expect(game.isPausedNotifier.value, isFalse);

      // Score and coins updates
      game.scoreNotifier.value += 100;
      game.coinsNotifier.value += 1;
      expect(game.scoreNotifier.value, equals(100));
      expect(game.coinsNotifier.value, equals(1));
    });
  });
}
