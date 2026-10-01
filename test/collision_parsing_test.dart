import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cowboycavead/game/components/solid_block.dart';
import 'package:cowboycavead/game/loaders/ldtk_level_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 3: Solid Collision Parsing & Hitboxes', () {
    test('Parses collision boxes from assets/backy.ldtk Level_0 with merging', () async {
      final levelData = await LdtkLevelLoader.loadLevel(
        'assets/backy.ldtk',
        levelId: 'Level_0',
      );

      expect(levelData.collisionBoxes.isNotEmpty, isTrue);

      // 1. Verify Ground Floor Horizontal Merge:
      // The 16 consecutive ground tiles at y = 240 must be merged into 1 continuous box (x = 0, width = 256)
      final groundBoxes = levelData.collisionBoxes.where((b) => b.y == 240).toList();
      expect(groundBoxes.length, equals(1));
      expect(groundBoxes.first.x, equals(0.0));
      expect(groundBoxes.first.y, equals(240.0));
      expect(groundBoxes.first.width, equals(256.0));
      expect(groundBoxes.first.height, equals(16.0));

      // 2. Verify Left & Right Border Walls
      final leftWallBoxes = levelData.collisionBoxes.where((b) => b.x == 0).toList();
      final rightWallBoxes = levelData.collisionBoxes.where((b) => (b.x + b.width) == 256).toList();

      expect(leftWallBoxes.isNotEmpty, isTrue);
      expect(rightWallBoxes.isNotEmpty, isTrue);

      // 3. Verify Ledges at y = 32 connected to outer walls:
      // Left ledge: cols 0..5 (x = 0, width = 96)
      // Right ledge: cols 10..15 (x = 160, width = 96)
      final y32Boxes = levelData.collisionBoxes.where((b) => b.y == 32).toList();
      expect(y32Boxes.length, equals(2));

      final leftSpan = y32Boxes.firstWhere((b) => b.x == 0);
      expect(leftSpan.width, equals(96.0)); // 6 tiles * 16px

      final rightSpan = y32Boxes.firstWhere((b) => b.x == 160);
      expect(rightSpan.width, equals(96.0)); // 6 tiles * 16px
    });

    test('SolidBlock has RectangleHitbox with CollisionType.passive', () async {
      final solidBlock = SolidBlock(
        position: Vector2(0, 240),
        size: Vector2(256, 16),
      );

      await solidBlock.onLoad();

      expect(solidBlock.hitbox, isNotNull);
      expect(solidBlock.hitbox.collisionType, equals(CollisionType.passive));
      expect(solidBlock.hitbox.size, equals(Vector2(256, 16)));
    });
  });
}
