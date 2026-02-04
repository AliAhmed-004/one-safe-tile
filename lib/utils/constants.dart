import 'package:flutter/material.dart';

/// Game configuration constants
class GameConstants {
  // Prevent instantiation
  GameConstants._();

  // ============ GRID SETTINGS ============
  /// Number of tiles per row
  static const int tilesPerRow = 5;

  /// Tile dimensions (calculated dynamically based on screen width)
  static const double tileSpacing = 2.0;

  // ============ SCROLL SETTINGS ============
  /// Initial scroll speed (pixels per second)
  static const double initialScrollSpeed = 100.0;

  /// Maximum scroll speed
  static const double maxScrollSpeed = 300.0;

  /// Speed increase per difficulty level
  static const double speedIncrement = 10.0;

  /// Score threshold for speed increase
  static const int difficultyIncreaseInterval = 5;

  // ============ PLAYER SETTINGS ============
  /// Player size (width and height)
  static const double playerSize = 40.0;

  /// Jump duration in seconds
  static const double jumpDuration = 0.3;

  /// Horizontal movement speed (pixels per second)
  static const double playerMoveSpeed = 300.0;

  // ============ CONTROLS SETTINGS ============
  /// Joystick size
  static const double joystickSize = 120.0;

  /// Jump button size
  static const double jumpButtonSize = 80.0;

  /// Margin from screen edges for controls
  static const double controlsMargin = 20.0;
}

/// Game color palette
class GameColors {
  // Prevent instantiation
  GameColors._();

  // ============ BACKGROUND ============
  static const Color background = Color(0xFF1A1A2E);

  // ============ TILE COLORS ============
  /// Dangerous tile color
  static const Color dangerousTile = Color(0xFF16213E);

  /// Safe tile color (revealed on landing)
  static const Color safeTile = Color(0xFF0F3460);

  /// Safe tile highlight (when player lands correctly)
  static const Color safeTileHighlight = Color(0xFF00FF88);

  /// Dangerous tile highlight (when player lands incorrectly)
  static const Color dangerousTileHighlight = Color(0xFFFF4444);

  // ============ PLAYER COLORS ============
  static const Color player = Color(0xFFE94560);
  static const Color playerOutline = Color(0xFFFFFFFF);

  // ============ UI COLORS ============
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color buttonPrimary = Color(0xFFE94560);
  static const Color buttonSecondary = Color(0xFF0F3460);

  // ============ HUD COLORS ============
  static const Color joystickBackground = Color(0x44FFFFFF);
  static const Color joystickKnob = Color(0xAAFFFFFF);
  static const Color jumpButton = Color(0xFFE94560);
}
