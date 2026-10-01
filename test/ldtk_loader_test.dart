import 'package:flutter_test/flutter_test.dart';
import 'package:cowboycavead/game/loaders/ldtk_level_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LDtk Level Loader Tests', () {
    test('Loads and parses assets/backy.ldtk Level_0 successfully', () async {
      final levelData = await LdtkLevelLoader.loadLevel(
        'assets/backy.ldtk',
        levelId: 'Level_0',
      );

      // Verify level metadata
      expect(levelData.identifier, equals('Level_0'));
      expect(levelData.width, equals(256.0));
      expect(levelData.height, equals(256.0));
      expect(levelData.bgColorHex, isNotNull);

      // Verify tilesets mapping
      expect(levelData.tilesets.containsKey(1), isTrue); // Platforms
      expect(levelData.tilesets.containsKey(2), isTrue); // World_Tiles

      final worldTileset = levelData.tilesets[2]!;
      expect(worldTileset.imageFileName, equals('world_tileset.png'));
      expect(worldTileset.tileGridSize, equals(16.0));

      final platformsTileset = levelData.tilesets[1]!;
      expect(platformsTileset.imageFileName, equals('platforms.png'));
      expect(platformsTileset.tileGridSize, equals(16.0));

      // Verify tile layers
      expect(levelData.tileLayers.isNotEmpty, isTrue);

      final tilesLayer = levelData.tileLayers.firstWhere(
        (l) => l.identifier == 'Tiles',
      );
      expect(tilesLayer.tiles.isNotEmpty, isTrue);

      // Check ground floor tiles (y = 240)
      final groundTiles = tilesLayer.tiles.where((t) => t.pxY == 240).toList();
      expect(groundTiles.length, equals(16)); // 16 tiles of 16px span 256px

      // Check left/right border walls
      final leftWallTiles = tilesLayer.tiles.where((t) => t.pxX == 0).toList();
      final rightWallTiles = tilesLayer.tiles.where((t) => t.pxX == 240).toList();
      expect(leftWallTiles.length, greaterThanOrEqualTo(10));
      expect(rightWallTiles.length, greaterThanOrEqualTo(10));
    });
  });
}
