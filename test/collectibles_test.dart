import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cowboycavead/game/components/collectibles/coin_component.dart';
import 'package:cowboycavead/game/components/collectibles/fruit_component.dart';
import 'package:cowboycavead/game/components/collectibles/potion_component.dart';
import 'package:cowboycavead/game/components/knight_player.dart';
import 'package:cowboycavead/game/cowboy_cave_game.dart';
import 'package:cowboycavead/game/loaders/ldtk_level_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 6: Collectibles & Items Tests', () {
    test('Parses all 8 coins and 1 fruit from assets/backy.ldtk', () async {
      final levelData = await LdtkLevelLoader.loadLevel(
        'assets/backy.ldtk',
        levelId: 'Level_0',
      );

      final coins = levelData.entities.where((e) => e.identifier == 'Coin').toList();
      final fruits = levelData.entities.where((e) => e.identifier == 'Fruit').toList();

      expect(coins.length, equals(8));
      expect(fruits.length, equals(1));
      expect(fruits.first.x, equals(96.0));
      expect(fruits.first.y, equals(112.0));
    });

    test('CoinComponent collection increments score by 10 and coins by 1', () {
      final game = CowboyCaveGame(levelNumber: 1);
      final coin = CoinComponent(position: Vector2(64, 224));
      coin.game = game;

      final initialScore = game.scoreNotifier.value;
      final initialCoins = game.coinsNotifier.value;

      coin.collect();

      expect(game.scoreNotifier.value, equals(initialScore + 10));
      expect(game.coinsNotifier.value, equals(initialCoins + 1));
    });

    test('FruitComponent collection increments score by 50 and restores 1 life', () {
      final game = CowboyCaveGame(levelNumber: 1);
      final fruit = FruitComponent(position: Vector2(96, 112));
      fruit.game = game;

      // Damage player by 1 heart
      game.livesNotifier.value = 2;
      final initialScore = game.scoreNotifier.value;

      fruit.collect();

      expect(game.scoreNotifier.value, equals(initialScore + 50));
      expect(game.livesNotifier.value, equals(3)); // Restored to 3!
    });

    test('PotionComponent grants speed boost multiplier and bonus score', () {
      final game = CowboyCaveGame(levelNumber: 1);
      final player = KnightPlayer(spawnPosition: Vector2(48, 16));
      player.game = game;
      final potion = PotionComponent(position: Vector2(48, 16));
      potion.game = game;

      final initialScore = game.scoreNotifier.value;

      expect(player.isSpeedBoostActive, isFalse);

      potion.collect(player);

      expect(game.scoreNotifier.value, equals(initialScore + 25));
      expect(player.isSpeedBoostActive, isTrue);

      // Verify speed boost is applied in update
      player.startMovingRight();
      player.update(0.016);
      expect(player.velocity.x, closeTo(KnightPlayer.moveSpeed * 1.45, 0.001));

      // Stop moving and advance time by 8.1 seconds to verify expiry
      player.stopMovingRight();
      player.update(8.1);
      expect(player.isSpeedBoostActive, isFalse);

      // Verify speed returns to normal (1.0x moveSpeed)
      player.startMovingRight();
      player.update(0.016);
      expect(player.velocity.x, equals(KnightPlayer.moveSpeed));
    });
  });
}
