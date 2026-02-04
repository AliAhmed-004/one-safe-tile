import 'dart:math';

import 'package:flame/components.dart';

import '../utils/constants.dart';
import 'tile.dart';

/// A row of platform tiles that scrolls downward.
/// 
/// Each row contains exactly one safe tile, randomly positioned.
/// Styled like Icy Tower platforms - thin horizontal sticks.
class TileRow extends PositionComponent {
  /// The index of the safe tile in this row (0 to tilesPerRow-1)
  final int safeTileIndex;

  /// Row index/number for tracking player progress
  final int rowIndex;

  /// List of tile components in this row
  final List<Tile> tiles = [];

  /// Width of each tile (calculated based on screen width)
  late double tileWidth;

  /// Height of each tile (platform height)
  final double tileHeight = GameConstants.platformHeight;

  TileRow({
    required this.safeTileIndex,
    required this.rowIndex,
    required Vector2 position,
    required double screenWidth,
  }) : super(position: position) {
    _createTiles(screenWidth);
  }

  /// Factory constructor that randomly selects the safe tile
  factory TileRow.random({
    required int rowIndex,
    required Vector2 position,
    required double screenWidth,
    Random? random,
  }) {
    final rng = random ?? Random();
    final safeTileIndex = rng.nextInt(GameConstants.tilesPerRow);

    return TileRow(
      safeTileIndex: safeTileIndex,
      rowIndex: rowIndex,
      position: position,
      screenWidth: screenWidth,
    );
  }

  /// Creates all tiles for this row
  void _createTiles(double screenWidth) {
    final totalSpacing = GameConstants.tileSpacing * (GameConstants.tilesPerRow + 1);
    tileWidth = (screenWidth - totalSpacing) / GameConstants.tilesPerRow;

    for (int i = 0; i < GameConstants.tilesPerRow; i++) {
      final tileX = GameConstants.tileSpacing + i * (tileWidth + GameConstants.tileSpacing);
      
      final tile = Tile(
        isSafe: i == safeTileIndex,
        index: i,
        position: Vector2(tileX, 0),
        size: Vector2(tileWidth, tileHeight),
      );

      tiles.add(tile);
      add(tile);
    }
  }

  /// Gets the tile at a specific x position, or null if not found
  Tile? getTileAtX(double x) {
    for (final tile in tiles) {
      final absoluteX = position.x + tile.position.x;
      if (x >= absoluteX && x <= absoluteX + tile.size.x) {
        return tile;
      }
    }
    return null;
  }

  /// Gets the safe tile in this row
  Tile get safeTile => tiles[safeTileIndex];

  /// Gets the center X position of the safe tile (in world coordinates)
  double get safeTileCenterX {
    final tile = safeTile;
    return position.x + tile.position.x + tile.size.x / 2;
  }

  /// Checks if a point (in world coordinates) is within this row's Y bounds
  bool containsY(double y) {
    return y >= position.y && y <= position.y + tileHeight;
  }

  /// Reveals all tiles in this row (when row scrolls past player)
  void revealAll() {
    for (final tile in tiles) {
      tile.reveal(playerLanded: false);
    }
  }
}

