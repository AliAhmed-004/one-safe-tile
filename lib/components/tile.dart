import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Represents a single tile in the game grid.
/// 
/// Each tile can be either safe or dangerous. All tiles look identical
/// until the player lands on them (to prevent cheating by visual cues).
class Tile extends RectangleComponent {
  /// Whether this tile is safe to land on
  final bool isSafe;

  /// Index of this tile within its row (0 to tilesPerRow-1)
  final int index;

  /// Whether this tile has been revealed (player landed on it)
  bool _isRevealed = false;

  /// Debug mode: show safe tiles in green (for testing)
  static bool debugShowSafeTiles = true;

  Tile({
    required this.isSafe,
    required this.index,
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          // In debug mode, show safe tiles as green
          paint: Paint()..color = (debugShowSafeTiles && isSafe) 
              ? GameColors.safeTileHighlight 
              : GameColors.dangerousTile,
        );

  /// Reveals the tile's true color (safe or dangerous)
  void reveal({required bool playerLanded}) {
    if (_isRevealed) return;
    _isRevealed = true;

    if (playerLanded) {
      // Show result color based on whether tile is safe
      paint.color = isSafe 
          ? GameColors.safeTileHighlight 
          : GameColors.dangerousTileHighlight;
    } else {
      // Just show the safe tile indicator (for tiles player passed)
      if (isSafe) {
        paint.color = GameColors.safeTile;
      }
    }
  }

  /// Checks if a point is within this tile's bounds
  bool containsPoint(Vector2 point) {
    return point.x >= position.x &&
        point.x <= position.x + size.x &&
        point.y >= position.y &&
        point.y <= position.y + size.y;
  }

  /// Resets the tile to unrevealed state
  void reset() {
    _isRevealed = false;
    paint.color = GameColors.dangerousTile;
  }

  bool get isRevealed => _isRevealed;
}

