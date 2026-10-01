import 'dart:convert';
import 'package:flutter/services.dart';

/// Representation of an entity placed in an LDtk level (PlayerSpawn, Coin, Slime, Fruit, etc.).
class LdtkEntity {
  const LdtkEntity({
    required this.identifier,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory LdtkEntity.fromJson(Map<String, dynamic> json) {
    final px = (json['px'] as List<dynamic>?) ?? [0, 0];
    return LdtkEntity(
      identifier: json['__identifier'] as String? ?? '',
      x: (px[0] as num).toDouble(),
      y: (px[1] as num).toDouble(),
      width: (json['width'] as num?)?.toDouble() ?? 16.0,
      height: (json['height'] as num?)?.toDouble() ?? 16.0,
    );
  }

  final String identifier;
  final double x;
  final double y;
  final double width;
  final double height;
}

/// Representation of a static solid collision bounding box in world space.
class LdtkCollisionBox {
  const LdtkCollisionBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;
}

/// Representation of a tileset defined in an LDtk project.
class LdtkTilesetDef {
  const LdtkTilesetDef({
    required this.uid,
    required this.identifier,
    required this.imagePath,
    required this.imageFileName,
    required this.tileGridSize,
    required this.pxWid,
    required this.pxHei,
  });

  factory LdtkTilesetDef.fromJson(Map<String, dynamic> json) {
    final relPath = json['relPath'] as String? ?? '';
    final fileName = relPath.split('/').last.split('\\').last;

    return LdtkTilesetDef(
      uid: json['uid'] as int,
      identifier: json['identifier'] as String? ?? '',
      imagePath: relPath,
      imageFileName: fileName,
      tileGridSize: (json['tileGridSize'] as num?)?.toDouble() ?? 16.0,
      pxWid: (json['pxWid'] as num?)?.toDouble() ?? 256.0,
      pxHei: (json['pxHei'] as num?)?.toDouble() ?? 256.0,
    );
  }

  final int uid;
  final String identifier;
  final String imagePath;
  final String imageFileName;
  final double tileGridSize;
  final double pxWid;
  final double pxHei;
}

/// Representation of a single tile instance placed in a layer.
class LdtkTile {
  const LdtkTile({
    required this.pxX,
    required this.pxY,
    required this.srcX,
    required this.srcY,
    required this.width,
    required this.height,
    required this.flipBits,
    required this.tileId,
    required this.alpha,
    this.tilesetUid,
  });

  factory LdtkTile.fromJson(
    Map<String, dynamic> json,
    double defaultGridSize, {
    int? defaultTilesetUid,
  }) {
    final pxList = (json['px'] as List<dynamic>?) ?? [0, 0];
    final srcList = (json['src'] as List<dynamic>?) ?? [0, 0];

    return LdtkTile(
      pxX: (pxList[0] as num).toDouble(),
      pxY: (pxList[1] as num).toDouble(),
      srcX: (srcList[0] as num).toDouble(),
      srcY: (srcList[1] as num).toDouble(),
      width: (json['w'] as num?)?.toDouble() ?? defaultGridSize,
      height: (json['h'] as num?)?.toDouble() ?? defaultGridSize,
      flipBits: (json['f'] as num?)?.toInt() ?? 0,
      tileId: (json['t'] as num?)?.toInt() ?? 0,
      alpha: (json['a'] as num?)?.toDouble() ?? 1.0,
      tilesetUid: (json['tilesetUid'] as num?)?.toInt() ?? defaultTilesetUid,
    );
  }

  final double pxX;
  final double pxY;
  final double srcX;
  final double srcY;
  final double width;
  final double height;
  final int flipBits; // 0: none, 1: flipX, 2: flipY, 3: flipBoth
  final int tileId;
  final double alpha;
  final int? tilesetUid;

  bool get flipX => (flipBits & 1) != 0;
  bool get flipY => (flipBits & 2) != 0;
}

/// Representation of a tile layer containing visual tiles.
class LdtkTileLayer {
  const LdtkTileLayer({
    required this.identifier,
    required this.type,
    required this.gridSize,
    required this.opacity,
    required this.tilesetDefUid,
    required this.tiles,
  });

  factory LdtkTileLayer.fromJson(Map<String, dynamic> json) {
    final identifier = json['__identifier'] as String? ?? '';
    final type = json['__type'] as String? ?? '';
    final gridSize = (json['__gridSize'] as num?)?.toDouble() ?? 16.0;
    final opacity = (json['__opacity'] as num?)?.toDouble() ?? 1.0;
    final tilesetDefUid = (json['overrideTilesetUid'] ?? json['__tilesetDefUid']) as int?;

    final tiles = <LdtkTile>[];

    // 1. Parse gridTiles (explicit placed tiles)
    final gridTilesJson = json['gridTiles'] as List<dynamic>?;
    if (gridTilesJson != null) {
      for (final t in gridTilesJson) {
        if (t is Map<String, dynamic>) {
          tiles.add(LdtkTile.fromJson(t, gridSize, defaultTilesetUid: tilesetDefUid));
        }
      }
    }

    // 2. Parse autoLayerTiles (rule-based generated tiles)
    final autoTilesJson = json['autoLayerTiles'] as List<dynamic>?;
    if (autoTilesJson != null) {
      for (final t in autoTilesJson) {
        if (t is Map<String, dynamic>) {
          tiles.add(LdtkTile.fromJson(t, gridSize, defaultTilesetUid: tilesetDefUid));
        }
      }
    }

    return LdtkTileLayer(
      identifier: identifier,
      type: type,
      gridSize: gridSize,
      opacity: opacity,
      tilesetDefUid: tilesetDefUid,
      tiles: tiles,
    );
  }

  final String identifier;
  final String type;
  final double gridSize;
  final double opacity;
  final int? tilesetDefUid;
  final List<LdtkTile> tiles;
}

/// Parsed Level Data for single-screen arena.
class LdtkLevelData {
  const LdtkLevelData({
    required this.identifier,
    required this.width,
    required this.height,
    required this.bgColorHex,
    required this.tilesets,
    required this.tileLayers,
    required this.collisionBoxes,
    required this.entities,
  });

  final String identifier;
  final double width;
  final double height;
  final String? bgColorHex;
  final Map<int, LdtkTilesetDef> tilesets;
  final List<LdtkTileLayer> tileLayers;
  final List<LdtkCollisionBox> collisionBoxes;
  final List<LdtkEntity> entities;

  /// Returns the PlayerSpawn entity, if present.
  LdtkEntity? get playerSpawn {
    for (final e in entities) {
      if (e.identifier == 'PlayerSpawn') return e;
    }
    return null;
  }

  /// Returns the Exit gate entity, if present.
  LdtkEntity? get exitGate {
    for (final e in entities) {
      if (e.identifier == 'Exit' || e.identifier == 'Gate' || e.identifier == 'ExitGate') {
        return e;
      }
    }
    return null;
  }

  /// Returns the tileset definition for a given UID or the first available tileset.
  LdtkTilesetDef? getTileset(int? uid) {
    if (uid != null && tilesets.containsKey(uid)) {
      return tilesets[uid];
    }
    if (tilesets.isNotEmpty) {
      return tilesets.values.first;
    }
    return null;
  }
}

/// Static loader and decoder for LDtk JSON level files.
abstract final class LdtkLevelLoader {
  /// Loads an LDtk level from assets.
  static Future<LdtkLevelData> loadLevel(
    String assetPath, {
    String levelId = 'Level_0',
  }) async {
    final rawJsonString = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> rootJson = jsonDecode(rawJsonString) as Map<String, dynamic>;

    return parseLevelFromJson(rootJson, levelId: levelId);
  }

  /// Parses LDtk JSON object into `LdtkLevelData`.
  static LdtkLevelData parseLevelFromJson(
    Map<String, dynamic> rootJson, {
    String levelId = 'Level_0',
  }) {
    // 1. Parse tilesets definitions
    final tilesetsMap = <int, LdtkTilesetDef>{};
    final defs = rootJson['defs'] as Map<String, dynamic>?;
    if (defs != null) {
      final tilesetsList = defs['tilesets'] as List<dynamic>?;
      if (tilesetsList != null) {
        for (final item in tilesetsList) {
          if (item is Map<String, dynamic>) {
            final tileset = LdtkTilesetDef.fromJson(item);
            tilesetsMap[tileset.uid] = tileset;
          }
        }
      }
    }

    // 2. Locate target level
    final levels = rootJson['levels'] as List<dynamic>? ?? [];
    Map<String, dynamic>? levelJson;

    for (final lvl in levels) {
      if (lvl is Map<String, dynamic> && lvl['identifier'] == levelId) {
        levelJson = lvl;
        break;
      }
    }

    // Fallback to first level if levelId not found
    if (levelJson == null && levels.isNotEmpty) {
      levelJson = levels.first as Map<String, dynamic>;
    }

    if (levelJson == null) {
      throw StateError('No valid level found in LDtk data.');
    }

    final identifier = levelJson['identifier'] as String? ?? levelId;
    final width = (levelJson['pxWid'] as num?)?.toDouble() ?? 256.0;
    final height = (levelJson['pxHei'] as num?)?.toDouble() ?? 256.0;
    final bgColor = (levelJson['__bgColor'] ?? levelJson['bgColor'] ?? rootJson['defaultLevelBgColor']) as String?;

    // 3. Parse visual tile layers and entities
    final layerInstances = levelJson['layerInstances'] as List<dynamic>? ?? [];
    final tileLayers = <LdtkTileLayer>[];
    final entities = <LdtkEntity>[];

    for (int i = layerInstances.length - 1; i >= 0; i--) {
      final layerMap = layerInstances[i];
      if (layerMap is Map<String, dynamic>) {
        final type = layerMap['__type'] as String? ?? '';
        final isVisible = layerMap['visible'] as bool? ?? true;

        // Parse Entity Instances
        if (type == 'Entities') {
          final entityInstancesJson = layerMap['entityInstances'] as List<dynamic>?;
          if (entityInstancesJson != null) {
            for (final ent in entityInstancesJson) {
              if (ent is Map<String, dynamic>) {
                entities.add(LdtkEntity.fromJson(ent));
              }
            }
          }
        }

        if (!isVisible) continue;

        // Check if layer contains tiles (Type == 'Tiles' or has gridTiles/autoLayerTiles)
        final hasGridTiles = (layerMap['gridTiles'] as List<dynamic>?)?.isNotEmpty ?? false;
        final hasAutoTiles = (layerMap['autoLayerTiles'] as List<dynamic>?)?.isNotEmpty ?? false;

        if (type == 'Tiles' || hasGridTiles || hasAutoTiles) {
          tileLayers.add(LdtkTileLayer.fromJson(layerMap));
        }
      }
    }

    // 4. Parse Collisions & Generate Optimized Collision Hitboxes
    final collisionBoxes = _extractCollisionBoxes(
      layerInstances: layerInstances,
      levelWidth: width,
      levelHeight: height,
      tileLayers: tileLayers,
    );

    return LdtkLevelData(
      identifier: identifier,
      width: width,
      height: height,
      bgColorHex: bgColor,
      tilesets: tilesetsMap,
      tileLayers: tileLayers,
      collisionBoxes: collisionBoxes,
      entities: entities,
    );
  }

  /// Extracts solid blocks from the 'Collisions' IntGrid layer and optimizes by merging horizontal spans.
  static List<LdtkCollisionBox> _extractCollisionBoxes({
    required List<dynamic> layerInstances,
    required double levelWidth,
    required double levelHeight,
    required List<LdtkTileLayer> tileLayers,
  }) {
    const double gridSize = 16.0;
    final int cols = (levelWidth / gridSize).round();
    final int rows = (levelHeight / gridSize).round();

    // 2D grid matrix: 1 = solid, 0 = air/empty
    final grid = List.generate(rows, (_) => List.filled(cols, 0));

    Map<String, dynamic>? collisionsLayer;
    for (final l in layerInstances) {
      if (l is Map<String, dynamic> && l['__identifier'] == 'Collisions') {
        collisionsLayer = l;
        break;
      }
    }

    bool hasSolidIntGrid = false;
    if (collisionsLayer != null) {
      final intGridCsv = collisionsLayer['intGridCsv'] as List<dynamic>?;
      if (intGridCsv != null && intGridCsv.isNotEmpty) {
        for (int i = 0; i < intGridCsv.length && i < rows * cols; i++) {
          final val = (intGridCsv[i] as num).toInt();
          if (val == 1) { // 1 = Solid
            final r = i ~/ cols;
            final c = i % cols;
            grid[r][c] = 1;
            hasSolidIntGrid = true;
          }
        }
      }
    }

    // Fallback: If IntGrid has no solid values in this LDtk export, populate from solid visual tiles
    if (!hasSolidIntGrid) {
      for (final layer in tileLayers) {
        for (final tile in layer.tiles) {
          final c = (tile.pxX / gridSize).floor();
          final r = (tile.pxY / gridSize).floor();
          if (r >= 0 && r < rows && c >= 0 && c < cols) {
            grid[r][c] = 1;
          }
        }
      }
    }

    // Horizontal Span Merging Optimization:
    // Combines consecutive horizontal solid cells in each row into single continuous bounding boxes.
    final mergedBoxes = <LdtkCollisionBox>[];

    for (int r = 0; r < rows; r++) {
      int c = 0;
      while (c < cols) {
        if (grid[r][c] == 1) {
          final startCol = c;
          while (c + 1 < cols && grid[r][c + 1] == 1) {
            c++;
          }
          final spanCols = c - startCol + 1;
          mergedBoxes.add(
            LdtkCollisionBox(
              x: startCol * gridSize,
              y: r * gridSize,
              width: spanCols * gridSize,
              height: gridSize,
            ),
          );
        }
        c++;
      }
    }

    return mergedBoxes;
  }
}
