import 'package:flutter/material.dart';

/// Game configuration constants
class GameConstants {
  // Prevent instantiation
  GameConstants._();

  // ============ LAYOUT SETTINGS ============
  /// Height of the top HUD area (score, pause button)
  static const double hudAreaHeight = 60.0;

  /// Height of the bottom controls area (joystick, jump button)
  static const double controlsAreaHeight = 160.0;

  /// Padding inside the arena from its border
  static const double arenaPadding = 8.0;

  /// Border width for arena
  static const double arenaBorderWidth = 2.0;

  // ============ GRID SETTINGS ============
  /// Number of tiles per row
  static const int tilesPerRow = 5;

  /// Horizontal spacing between tiles
  static const double tileSpacing = 4.0;

  /// Platform/tile height (thin like Icy Tower platforms)
  static const double platformHeight = 20.0;

  /// Vertical spacing between rows (gap between platforms)
  static const double rowSpacing = 60.0;

  // ============ SCROLL SETTINGS ============
  /// Initial scroll speed (pixels per second)
  static const double initialScrollSpeed = 30.0;

  /// Maximum scroll speed
  static const double maxScrollSpeed = 150.0;

  /// Speed increase per difficulty level
  static const double speedIncrement = 5.0;

  /// Score threshold for speed increase
  static const int difficultyIncreaseInterval = 5;

  // ============ PLAYER SETTINGS ============
  /// Player size (width and height)
  static const double playerSize = 30.0;

  /// Jump duration in seconds (legacy - not used with physics)
  static const double jumpDuration = 0.35;

  /// Horizontal movement speed (pixels per second)
  static const double playerMoveSpeed = 400.0;

  // ============ CONTROLS SETTINGS ============
  /// Joystick size
  static const double joystickSize = 120.0;

  /// Jump button size
  static const double jumpButtonSize = 80.0;

  /// Margin from screen edges for controls
  static const double controlsMargin = 20.0;

  // ============ AIM SETTINGS (One-Hand Mode) ============
  /// Maximum aim drag distance in pixels (larger = need to drag further for full power)
  static const double aimMaxDistance = 150.0;

  /// Multiplier for horizontal velocity from aim (lower = less sensitive)
  /// - 1.0 = subtle horizontal movement
  /// - 1.5 = moderate (default)
  /// - 2.0+ = more sensitive
  static const double aimSensitivity = 1.5;
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

  // ============ ARENA COLORS ============
  static const Color arenaBorder = Color(0xFF3D5A80);
  static const Color arenaBackground = Color(0xFF0D1321);
  static const Color hudBackground = Color(0xFF1A1A2E);
  static const Color controlsBackground = Color(0xFF1A1A2E);
}
