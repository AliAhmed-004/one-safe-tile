import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Types of tiles available in the game.
///
/// This enum allows for future tile type expansion while maintaining
/// backward compatibility with the current safe/dangerous system.
///
/// ## Future Tile Ideas:
/// - [TileType.breaking] - Crumbles after landing, one-time use
/// - [TileType.fake] - Looks safe but is actually dangerous (reveals on proximity)
/// - [TileType.bouncy] - Bounces player higher than normal jump
/// - [TileType.sticky] - Slows player movement temporarily
/// - [TileType.teleport] - Teleports player to another tile
/// - [TileType.timed] - Only safe for a limited time window
/// - [TileType.moving] - Moves horizontally across the row
enum TileType {
  /// Standard dangerous tile - instant death on landing
  dangerous,

  /// Standard safe tile - scores a point on landing
  safe,

  // ============ FUTURE TILE TYPES ============
  // Uncomment and implement these as needed:
  //
  // /// Crumbles after landing - can only be used once
  // breaking,
  //
  // /// Appears safe but reveals as dangerous when player gets close
  // fake,
  //
  // /// Gives player extra jump height
  // bouncy,
  //
  // /// Slows player horizontal movement for a few seconds
  // sticky,
  //
  // /// Teleports player to a random safe tile in the next row
  // teleport,
  //
  // /// Alternates between safe/dangerous on a timer
  // timed,
  //
  // /// Moves left/right across the row
  // moving,
}

/// Extension methods for [TileType] to define behavior.
extension TileTypeBehavior on TileType {
  /// Whether this tile type is safe to land on.
  /// For special tiles, this may change based on state.
  bool get isSafe {
    switch (this) {
      case TileType.dangerous:
        return false;
      case TileType.safe:
        return true;
      // Future implementations:
      // case TileType.breaking:
      //   return true; // Safe first time
      // case TileType.fake:
      //   return false; // Actually dangerous
      // case TileType.bouncy:
      // case TileType.sticky:
      // case TileType.teleport:
      //   return true;
      // case TileType.timed:
      //   return _isInSafePhase; // Would need state
      // case TileType.moving:
      //   return true;
    }
  }

  /// The base color for this tile type (before reveal).
  Color get baseColor {
    switch (this) {
      case TileType.dangerous:
      case TileType.safe:
        return GameColors.dangerousTile; // All look the same initially
      // Future: different tile types could have subtle visual hints
    }
  }

  /// The color when revealed after landing.
  Color get revealColor {
    switch (this) {
      case TileType.dangerous:
        return GameColors.dangerousTileHighlight;
      case TileType.safe:
        return GameColors.safeTileHighlight;
      // Future implementations would return appropriate colors
    }
  }

  /// Score awarded for landing on this tile (0 for dangerous).
  int get scoreValue {
    switch (this) {
      case TileType.dangerous:
        return 0;
      case TileType.safe:
        return 1;
      // Future: bouncy/special tiles could give bonus points
    }
  }
}

/// Represents a single tile in the game grid.
///
/// Each tile has a [TileType] that determines its behavior. All tiles look
/// identical until the player lands on them (to prevent cheating by visual cues).
class Tile extends RectangleComponent {
  /// The type of this tile (determines behavior)
  final TileType tileType;

  /// Index of this tile within its row (0 to tilesPerRow-1)
  final int index;

  /// Whether this tile has been revealed (player landed on it)
  bool _isRevealed = false;

  /// Debug mode: show safe tiles in green (for testing)
  static bool debugShowSafeTiles = true;

  /// Flash animation timer
  double _flashTimer = 0;
  bool _isFlashing = false;
  Color _flashColor = Colors.transparent;
  Color _baseColor = GameColors.dangerousTile;

  /// Legacy getter for backward compatibility
  bool get isSafe => tileType.isSafe;

  Tile({
    required this.tileType,
    required this.index,
    required Vector2 position,
    required Vector2 size,
  }) : super(
         position: position,
         size: size,
         // In debug mode, show safe tiles as green
         paint: Paint()
           ..color = (debugShowSafeTiles && tileType.isSafe)
               ? GameColors.safeTileHighlight
               : tileType.baseColor,
       );

  /// Legacy constructor for backward compatibility.
  /// Creates a tile with either [TileType.safe] or [TileType.dangerous].
  factory Tile.legacy({
    required bool isSafe,
    required int index,
    required Vector2 position,
    required Vector2 size,
  }) {
    return Tile(
      tileType: isSafe ? TileType.safe : TileType.dangerous,
      index: index,
      position: position,
      size: size,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Handle flash animation
    if (_isFlashing) {
      _flashTimer += dt;

      // Flash duration: 0.4 seconds with quick fade
      const flashDuration = 0.4;
      if (_flashTimer >= flashDuration) {
        _isFlashing = false;
        paint.color = _baseColor;
      } else {
        // Interpolate from flash color back to base color
        final t = _flashTimer / flashDuration;
        paint.color = Color.lerp(_flashColor, _baseColor, t) ?? _baseColor;
      }
    }
  }

  /// Reveals the tile's true color (safe or dangerous)
  void reveal({required bool playerLanded}) {
    if (_isRevealed) return;
    _isRevealed = true;

    if (playerLanded) {
      // Show result color based on whether tile is safe
      if (isSafe) {
        // Flash bright then settle to highlight color
        _flashColor = Colors.white;
        _baseColor = GameColors.safeTileHighlight;
        _startFlash();

        // Add a subtle scale pop effect
        add(
          ScaleEffect.by(
            Vector2.all(1.1),
            EffectController(duration: 0.1, reverseDuration: 0.15),
          ),
        );
      } else {
        // Flash red for danger
        _flashColor = Colors.white;
        _baseColor = GameColors.dangerousTileHighlight;
        _startFlash();

        // Add shake effect for danger
        _addShakeEffect();
      }
    } else {
      // Just show the safe tile indicator (for tiles player passed)
      if (isSafe) {
        paint.color = GameColors.safeTile;
        _baseColor = GameColors.safeTile;
      }
    }
  }

  /// Starts a flash animation
  void _startFlash() {
    _isFlashing = true;
    _flashTimer = 0;
    paint.color = _flashColor;
  }

  /// Adds a shake effect to the tile (for danger landing)
  void _addShakeEffect() {
    add(
      SequenceEffect([
        MoveEffect.by(Vector2(-3, 0), EffectController(duration: 0.03)),
        MoveEffect.by(Vector2(6, 0), EffectController(duration: 0.03)),
        MoveEffect.by(Vector2(-6, 0), EffectController(duration: 0.03)),
        MoveEffect.by(Vector2(6, 0), EffectController(duration: 0.03)),
        MoveEffect.by(Vector2(-3, 0), EffectController(duration: 0.03)),
      ]),
    );
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
    _isFlashing = false;
    _flashTimer = 0;
    paint.color = GameColors.dangerousTile;
    _baseColor = GameColors.dangerousTile;
  }

  bool get isRevealed => _isRevealed;
}
