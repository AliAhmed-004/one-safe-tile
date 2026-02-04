import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../components/hud/joystick.dart';
import '../components/hud/jump_button.dart';
import '../components/player.dart';
import '../components/tile_row.dart';
import '../utils/constants.dart';

/// Main game class for One Safe Tile.
/// 
/// This is the central FlameGame instance that manages:
/// - Game world and components
/// - Game state (playing, paused, game over)
/// - Score tracking
/// - Difficulty scaling
class OneSafeTileGame extends FlameGame {
  // ============ GAME STATE ============
  /// Current player score
  int score = 0;

  /// Current scroll speed (increases with difficulty)
  double scrollSpeed = GameConstants.initialScrollSpeed;

  /// Game state flags
  bool isGameOver = false;
  bool isPaused = false;

  // ============ COMPONENTS ============
  /// The player character
  late Player player;

  /// List of active tile rows
  final List<TileRow> rows = [];

  /// Joystick for horizontal movement
  late GameJoystick joystick;

  /// Jump button
  late JumpButton jumpButton;

  // ============ GAME CONFIG ============
  /// Distance between rows (vertical spacing)
  double get rowSpacing => GameConstants.rowSpacing + GameConstants.platformHeight;

  /// Current row index (for spawning new rows)
  int _nextRowIndex = 0;

  /// Random number generator for row generation
  final Random _random = Random();

  /// Y position where new rows spawn (top of screen)
  late double _spawnY;

  /// Y position where rows are removed (bottom of screen, above HUD)
  late double _despawnY;

  /// Space reserved for HUD at bottom
  static const double _hudHeight = 150.0;

  @override
  Color backgroundColor() => GameColors.background;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set spawn/despawn positions (rows spawn at top, despawn at bottom)
    _spawnY = -GameConstants.platformHeight;
    _despawnY = size.y - _hudHeight;

    // Initialize game components
    await _initializeRows();
    await _initializePlayer();
    await _initializeHUD();

    debugPrint('OneSafeTileGame loaded - Screen: ${size.x}x${size.y}');
  }

  /// Creates initial rows on the screen
  Future<void> _initializeRows() async {
    // Calculate how many rows fit on screen
    final playAreaHeight = size.y - _hudHeight;
    final numRows = (playAreaHeight / rowSpacing).ceil() + 3;

    // Spawn initial rows from top to bottom
    for (int i = 0; i < numRows; i++) {
      final rowY = _spawnY + (i * rowSpacing);
      _spawnRow(atY: rowY);
    }
  }

  /// Creates the player at starting position
  Future<void> _initializePlayer() async {
    // Find a row that's in the lower portion of the play area but safely above despawn
    // We want to start on a row that's about 2/3 down the visible play area
    final targetY = (size.y - _hudHeight) * 0.6;
    
    // Find the row closest to this target position
    TileRow? startRow;
    double closestDistance = double.infinity;
    
    for (final row in rows) {
      final distance = (row.position.y - targetY).abs();
      if (distance < closestDistance && row.position.y < _despawnY - 50) {
        closestDistance = distance;
        startRow = row;
      }
    }
    
    // Fallback to first row if no suitable row found
    startRow ??= rows.first;

    // Position player at center of screen horizontally, on the starting row
    player = Player(
      position: Vector2(
        size.x / 2,
        startRow.position.y + GameConstants.platformHeight / 2,
      ),
    );

    debugPrint('Player starting at Y: ${player.position.y}, despawnY: $_despawnY');
    await add(player);
  }

  /// Creates the HUD (joystick and jump button)
  Future<void> _initializeHUD() async {
    // Position joystick in bottom-left
    joystick = GameJoystick(
      position: Vector2(
        GameConstants.controlsMargin + GameConstants.joystickSize / 2,
        size.y - GameConstants.controlsMargin - GameConstants.joystickSize / 2,
      ),
      onInputChanged: (input) {
        player.setHorizontalInput(input);
      },
    );

    // Position jump button in bottom-right
    jumpButton = JumpButton(
      position: Vector2(
        size.x - GameConstants.controlsMargin - GameConstants.jumpButtonSize / 2,
        size.y - GameConstants.controlsMargin - GameConstants.jumpButtonSize / 2,
      ),
      onPressed: _onJumpPressed,
    );

    // Add HUD components with high priority so they render on top
    await add(joystick);
    await add(jumpButton);
  }

  /// Gets the current difficulty level (0.0 to 1.0)
  /// Starts at 0 and gradually increases based on score
  double get _currentDifficulty {
    // Difficulty increases from 0 to 1 over the first 50 points
    // After 50 points, it stays at max difficulty (1.0)
    const maxScoreForFullDifficulty = 50;
    return (score / maxScoreForFullDifficulty).clamp(0.0, 1.0);
  }

  /// Gets the safe tile index of the most recently spawned row
  int get _lastSafeTileIndex {
    if (rows.isEmpty) {
      // Start in the middle if no rows exist
      return GameConstants.tilesPerRow ~/ 2;
    }
    // Get the row with the lowest Y (highest on screen = most recent spawn)
    final newestRow = rows.reduce((a, b) => a.position.y < b.position.y ? a : b);
    return newestRow.safeTileIndex;
  }

  /// Spawns a new row at the specified Y position
  void _spawnRow({required double atY}) {
    final row = TileRow.algorithmic(
      rowIndex: _nextRowIndex++,
      position: Vector2(0, atY),
      screenWidth: size.x,
      previousSafeTileIndex: _lastSafeTileIndex,
      difficulty: _currentDifficulty,
      random: _random,
    );

    rows.add(row);
    add(row);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver || isPaused) return;

    // Update scroll position for all rows
    _updateScroll(dt);

    // Check if player fell behind (death condition)
    _checkDeathByScroll();
  }

  /// Updates the scroll position of all rows
  void _updateScroll(double dt) {
    final scrollDelta = scrollSpeed * dt;

    // Move all rows downward (player is climbing up)
    for (final row in rows) {
      row.position.y += scrollDelta;
    }

    // Also move player downward with the scroll (unless jumping)
    if (!player.isJumping) {
      player.position.y += scrollDelta;
    }

    // Remove rows that have scrolled off the bottom
    rows.removeWhere((row) {
      if (row.position.y > _despawnY) {
        row.removeFromParent();
        return true;
      }
      return false;
    });

    // Spawn new rows at the top as needed
    if (rows.isNotEmpty) {
      final highestRow = rows.reduce((a, b) => a.position.y < b.position.y ? a : b);
      if (highestRow.position.y > _spawnY + rowSpacing) {
        _spawnRow(atY: highestRow.position.y - rowSpacing);
      }
    }
  }

  /// Checks if player has fallen behind (scrolled off bottom)
  void _checkDeathByScroll() {
    if (player.position.y > _despawnY) {
      onPlayerDeath(reason: 'Fell behind!');
    }
  }

  /// Called when jump button is pressed
  void _onJumpPressed() {
    if (isGameOver || isPaused || player.isJumping) return;

    // Simply initiate jump - physics will handle the rest
    player.jump();
    debugPrint('Jump!');
  }

  /// Checks if the player has landed on a platform (called during falling)
  void checkPlayerLanding(double previousY) {
    final playerBottom = player.bottomY;
    
    // Check each row to see if player crossed through it
    for (final row in rows) {
      final platformTop = row.position.y;
      final platformBottom = row.position.y + GameConstants.platformHeight;
      
      // Check if player's bottom crossed the platform top (landing)
      // previousY bottom was above platform, current bottom is at or below platform top
      final prevBottom = previousY + player.size.y / 2;
      
      if (prevBottom <= platformTop && playerBottom >= platformTop && playerBottom <= platformBottom + 10) {
        // Player landed on this platform!
        _handleLanding(row);
        return;
      }
    }
  }

  /// Handles the player landing on a specific row
  void _handleLanding(TileRow row) {
    // Position player on top of the platform
    final landingY = row.position.y - player.size.y / 2 + 2;
    player.land(landingY);

    // Find which tile the player landed on
    final landedTile = row.getTileAtX(player.position.x);
    if (landedTile == null) {
      debugPrint('Landed between tiles!');
      onPlayerDeath(reason: 'Fell between tiles!');
      return;
    }

    // Reveal the tile
    landedTile.reveal(playerLanded: true);

    if (landedTile.isSafe) {
      // Success! Score a point
      onSuccessfulJump();
      debugPrint('Landed on safe tile! Row: ${row.rowIndex}');
    } else {
      // Landed on dangerous tile - game over
      onPlayerDeath(reason: 'Wrong tile!');
    }
  }

  /// Called when player successfully lands on a safe tile
  void onSuccessfulJump() {
    score++;
    _updateDifficulty();
    debugPrint('Score: $score');
  }

  /// Called when player dies
  void onPlayerDeath({String reason = 'Game Over'}) {
    isGameOver = true;
    debugPrint('Game Over! Reason: $reason, Final score: $score');
    // TODO: Show game over overlay
  }

  /// Increases difficulty based on current score
  void _updateDifficulty() {
    if (score % GameConstants.difficultyIncreaseInterval == 0) {
      scrollSpeed = (scrollSpeed + GameConstants.speedIncrement)
          .clamp(GameConstants.initialScrollSpeed, GameConstants.maxScrollSpeed);
      debugPrint('Difficulty increased! Speed: $scrollSpeed');
    }
  }

  /// Resets the game to initial state
  void resetGame() {
    // Reset state
    score = 0;
    scrollSpeed = GameConstants.initialScrollSpeed;
    isGameOver = false;
    isPaused = false;
    _nextRowIndex = 0;

    // Remove all rows
    for (final row in rows) {
      row.removeFromParent();
    }
    rows.clear();

    // Remove player
    player.removeFromParent();

    // Reinitialize
    _initializeRows();
    _initializePlayer();

    debugPrint('Game reset');
  }

  /// Pauses the game
  void pauseGame() {
    isPaused = true;
    pauseEngine();
  }

  /// Resumes the game
  void resumeGame() {
    isPaused = false;
    resumeEngine();
  }
}

