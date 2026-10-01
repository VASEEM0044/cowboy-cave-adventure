import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cowboycavead/game/components/exit_gate_component.dart';
import 'package:cowboycavead/game/components/knight_player.dart';
import 'package:cowboycavead/game/cowboy_cave_game.dart';
import 'package:cowboycavead/game/loaders/ldtk_level_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 10: Exit Gate & Victory Condition Tests', () {
    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers.global'),
        (MethodCall methodCall) async => 1,
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('xyz.luan/audioplayers'),
        (MethodCall methodCall) async => 1,
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => '.',
      );
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'audio_bgm_muted': false,
        'audio_sfx_muted': false,
      });
    });

    test('Parses Exit entity from assets/backy.ldtk Level_0', () async {
      final levelData = await LdtkLevelLoader.loadLevel(
        'assets/backy.ldtk',
        levelId: 'Level_0',
      );

      expect(levelData.exitGate, isNotNull);
      expect(levelData.exitGate!.x, equals(224.0));
      expect(levelData.exitGate!.y, equals(224.0));
      expect(levelData.exitGate!.identifier, equals('Exit'));
    });

    test('ExitGateComponent is locked when coins remain, unlocked when all coins collected', () {
      final game = CowboyCaveGame(levelNumber: 1);
      game.totalCoins = 5;
      game.coinsNotifier.value = 2;

      final gate = ExitGateComponent(position: Vector2(224, 224));
      gate.game = game;

      // When coins < totalCoins -> locked
      expect(gate.isUnlocked, isFalse);

      // When coins collected >= totalCoins -> unlocked
      game.coinsNotifier.value = 5;
      expect(gate.isUnlocked, isTrue);
    });

    test('Knight touching unlocked exit gate triggers completeLevel()', () {
      final game = CowboyCaveGame(levelNumber: 1);
      game.totalCoins = 3;
      game.coinsNotifier.value = 3;

      final gate = ExitGateComponent(position: Vector2(224, 224));
      gate.game = game;

      final knight = KnightPlayer(spawnPosition: Vector2(224, 224));
      knight.game = game;

      expect(game.isLevelCompleteNotifier.value, isFalse);

      gate.triggerVictory(knight);

      expect(game.isLevelCompleteNotifier.value, isTrue);
    });

    test('CowboyCaveGame restartLevel resets isLevelCompleteNotifier and exit gate', () {
      final game = CowboyCaveGame(levelNumber: 1);
      final knight = KnightPlayer(spawnPosition: Vector2(16, 208));
      knight.game = game;
      game.player = knight;

      final gate = ExitGateComponent(position: Vector2(224, 224));
      gate.game = game;
      game.exitGate = gate;

      game.completeLevel();
      expect(game.isLevelCompleteNotifier.value, isTrue);

      game.restartLevel();
      expect(game.isLevelCompleteNotifier.value, isFalse);
      expect(game.livesNotifier.value, equals(3));
      expect(game.coinsNotifier.value, equals(0));
    });
  });
}
