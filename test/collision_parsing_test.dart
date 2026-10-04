import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cowboycavead/game/components/solid_block.dart';
import 'package:cowboycavead/game/loaders/ldtk_level_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 3: Solid Collision Parsing & Hitboxes', () {
    test('Parses 16x16 collision boxes and background from assets/backy.ldtk Level_0', () async {
      final levelData = await LdtkLevelLoader.loadLevel(
        'assets/backy.ldtk',
        levelId: 'Level_0',
      );

      expect(levelData.collisionBoxes.isNotEmpty, isTrue);

      // Verify LDtk Background Image metadata
      expect(levelData.bgRelPath, isNotNull);
      expect(levelData.bgRelPath, contains('bg3.png'));
      expect(levelData.bgFileName, equals('bg3.png'));
      expect(levelData.bgPos, equals('Cover'));

      // 1. Verify Ground Floor (y = 240):
      // Exactly 16 individual 16x16 solid blocks spanning from x = 0 to x = 240
      final groundBoxes = levelData.collisionBoxes.where((b) => b.y == 240).toList();
      expect(groundBoxes.length, equals(16));
      for (int i = 0; i < 16; i++) {
        expect(groundBoxes.any((b) => b.x == i * 16.0 && b.width == 16.0 && b.height == 16.0), isTrue);
      }

      // 2. Verify Left & Right Border Walls
      final leftWallBoxes = levelData.collisionBoxes.where((b) => b.x == 0).toList();
      final rightWallBoxes = levelData.collisionBoxes.where((b) => b.x == 240).toList();

      expect(leftWallBoxes.isNotEmpty, isTrue);
      expect(rightWallBoxes.isNotEmpty, isTrue);

      // 3. Verify Ledges at y = 32:
      // Left ledge: cols 0..5 (x = 0, 16, 32, 48, 64, 80)
      // Right ledge: cols 10..15 (x = 160, 176, 192, 208, 224, 240)
      final y32Boxes = levelData.collisionBoxes.where((b) => b.y == 32).toList();
      expect(y32Boxes.length, equals(12));

      final leftSpan = y32Boxes.where((b) => b.x <= 80).toList();
      expect(leftSpan.length, equals(6));

      final rightSpan = y32Boxes.where((b) => b.x >= 160).toList();
      expect(rightSpan.length, equals(6));
    });

    test('SolidBlock has 16x16 RectangleHitbox with CollisionType.passive', () async {
      final solidBlock = SolidBlock(
        position: Vector2(0, 240),
        size: Vector2(16, 16),
      );

      await solidBlock.onLoad();

      expect(solidBlock.hitbox, isNotNull);
      expect(solidBlock.hitbox.collisionType, equals(CollisionType.passive));
      expect(solidBlock.hitbox.size, equals(Vector2(16, 16)));
    });
  });
}
