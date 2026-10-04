import 'dart:async';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../loaders/ldtk_level_loader.dart';

/// Flame Component that renders static LDtk tile layers.
///
/// Pre-bakes all visual tile layers and background into an efficient [ui.Picture]
/// for ultra-fast, single-draw-call performance at 60+ FPS.
class LdtkMapComponent extends PositionComponent with HasGameReference<FlameGame> {
  LdtkMapComponent(this.levelData)
      : super(
          position: Vector2.zero(),
          size: Vector2(levelData.width, levelData.height),
          anchor: Anchor.topLeft,
        );

  final LdtkLevelData levelData;
  ui.Picture? _cachedMapPicture;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    // 1. Load all unique tileset images referenced in levelData
    final imageMap = <int, ui.Image>{};

    for (final tileset in levelData.tilesets.values) {
      try {
        final image = await game.images.load(tileset.imageFileName);
        imageMap[tileset.uid] = image;
      } catch (e) {
        debugPrint('Warning: Could not load tileset image ${tileset.imageFileName}: $e');
      }
    }

    // 2. Pre-record the entire map canvas into a ui.Picture
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.x, size.y));

    // Optional background fill (only if no background image is configured)
    if (levelData.bgColorHex != null &&
        (levelData.bgFileName == null || levelData.bgFileName!.isEmpty)) {
      final color = _parseHexColor(levelData.bgColorHex!);
      final bgPaint = Paint()..color = color;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bgPaint);
    }

    // 3. Draw all visual tile layers in order
    for (final layer in levelData.tileLayers) {
      final layerOpacity = layer.opacity.clamp(0.0, 1.0);

      for (final tile in layer.tiles) {
        final tilesetUid = tile.tilesetUid ?? layer.tilesetDefUid;
        final tilesetDef = levelData.getTileset(tilesetUid);
        if (tilesetDef == null) continue;

        final image = imageMap[tilesetDef.uid];
        if (image == null) continue;

        final srcRect = Rect.fromLTWH(
          tile.srcX,
          tile.srcY,
          tile.width,
          tile.height,
        );

        final totalAlpha = (tile.alpha * layerOpacity).clamp(0.0, 1.0);
        final tilePaint = Paint()
          ..filterQuality = FilterQuality.none
          ..isAntiAlias = false
          ..color = Color.fromRGBO(255, 255, 255, totalAlpha);

        if (tile.flipX || tile.flipY) {
          canvas.save();
          final translateX = tile.pxX + (tile.flipX ? tile.width : 0);
          final translateY = tile.pxY + (tile.flipY ? tile.height : 0);
          canvas.translate(translateX, translateY);
          canvas.scale(tile.flipX ? -1 : 1, tile.flipY ? -1 : 1);
          canvas.drawImageRect(
            image,
            srcRect,
            Rect.fromLTWH(0, 0, tile.width, tile.height),
            tilePaint,
          );
          canvas.restore();
        } else {
          final dstRect = Rect.fromLTWH(
            tile.pxX,
            tile.pxY,
            tile.width,
            tile.height,
          );
          canvas.drawImageRect(image, srcRect, dstRect, tilePaint);
        }
      }
    }

    _cachedMapPicture = recorder.endRecording();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_cachedMapPicture != null) {
      canvas.drawPicture(_cachedMapPicture!);
    }
  }

  @override
  void onRemove() {
    _cachedMapPicture?.dispose();
    _cachedMapPicture = null;
    super.onRemove();
  }

  static Color _parseHexColor(String hexString) {
    var hex = hexString.replaceAll('#', '').trim();
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}
