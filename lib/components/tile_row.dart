import 'dart:math';

import 'package:flame/components.dart';

import '../utils/constants.dart';
import 'tile.dart';

/// A row of platform tiles that scrolls downward.
/// 
/// Each row contains exactly one safe tile, positioned algorithmically.
/// Styled like Icy Tower platforms - thin horizontal sticks.
class TileRow extends PositionComponent {
  /// The index of the safe tile in this row (0 to tilesPerRow-1)
  final int safeTileIndex;

  /// Row index/number for tracking player progress
  final int rowIndex;

  /// List of tile components in this row
  final List<Tile> tiles = [];

  /// Width of each tile (calculated based on arena width)
  late double tileWidth;

  /// Height of each tile (platform height)
  final double tileHeight = GameConstants.platformHeight;

  /// Left offset for the arena
  final double arenaLeft;

  TileRow({
    required this.safeTileIndex,
    required this.rowIndex,
    required Vector2 position,
    required double arenaWidth,
    this.arenaLeft = 0,
  }) : super(position: position) {
    _createTiles(arenaWidth);
  }

  /// Factory constructor that uses algorithmic safe tile placement
  /// 
  /// [previousSafeTileIndex] - The safe tile index from the previous row
  /// [difficulty] - A value from 0.0 (easy) to 1.0 (hard) that controls randomness
  ///   - At 0.0: Safe tile is always adjacent to the previous one (±1 position)
  ///   - At 1.0: Safe tile can be anywhere (fully random)
  factory TileRow.algorithmic({
    required int rowIndex,
    required Vector2 position,
    required double arenaWidth,
    required int previousSafeTileIndex,
    required double difficulty,
    double arenaLeft = 0,
    Random? random,
  }) {
    final rng = random ?? Random();
    final safeTileIndex = _calculateSafeTileIndex(
      previousIndex: previousSafeTileIndex,
      difficulty: difficulty,
      random: rng,
    );

    return TileRow(
      safeTileIndex: safeTileIndex,
      rowIndex: rowIndex,
      position: position,
      arenaWidth: arenaWidth,
      arenaLeft: arenaLeft,
    );
  }

  /// Calculates the safe tile index based on difficulty
  static int _calculateSafeTileIndex({
    required int previousIndex,
    required double difficulty,
    required Random random,
  }) {
    final tilesPerRow = GameConstants.tilesPerRow;
    
    // Clamp difficulty between 0 and 1
    final clampedDifficulty = difficulty.clamp(0.0, 1.0);
    
    // Calculate maximum allowed distance from previous safe tile
    // At difficulty 0: maxDistance = 1 (adjacent only)
    // At difficulty 1: maxDistance = tilesPerRow - 1 (can be anywhere)
    final maxDistance = 1 + ((tilesPerRow - 2) * clampedDifficulty).round();
    
    // Generate list of valid positions within the allowed range
    final validPositions = <int>[];
    for (int i = 0; i < tilesPerRow; i++) {
      final distance = (i - previousIndex).abs();
      if (distance <= maxDistance) {
        validPositions.add(i);
      }
    }
    
    // Optionally weight positions closer to the previous one (for smoother gameplay)
    if (clampedDifficulty < 0.5) {
      // Add extra weight to adjacent positions at low difficulty
      final adjacentPositions = validPositions
          .where((pos) => (pos - previousIndex).abs() <= 1)
          .toList();
      validPositions.addAll(adjacentPositions); // Double the chance for adjacent
    }
    
    // Pick a random position from valid ones
    return validPositions[random.nextInt(validPositions.length)];
  }

  /// Legacy factory constructor for fully random placement
  factory TileRow.random({
    required int rowIndex,
    required Vector2 position,
    required double arenaWidth,
    double arenaLeft = 0,
    Random? random,
  }) {
    final rng = random ?? Random();
    final safeTileIndex = rng.nextInt(GameConstants.tilesPerRow);

    return TileRow(
      safeTileIndex: safeTileIndex,
      rowIndex: rowIndex,
      position: position,
      arenaWidth: arenaWidth,
      arenaLeft: arenaLeft,
    );
  }

  /// Creates all tiles for this row
  void _createTiles(double arenaWidth) {
    final totalSpacing = GameConstants.tileSpacing * (GameConstants.tilesPerRow + 1);
    tileWidth = (arenaWidth - totalSpacing) / GameConstants.tilesPerRow;

    for (int i = 0; i < GameConstants.tilesPerRow; i++) {
      final tileX = arenaLeft + GameConstants.tileSpacing + i * (tileWidth + GameConstants.tileSpacing);
      
      // Use the new TileType system
      final tile = Tile(
        tileType: i == safeTileIndex ? TileType.safe : TileType.dangerous,
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

