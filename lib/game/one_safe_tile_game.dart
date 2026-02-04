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

  /// Score notifier for UI updates
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);

  /// Current scroll speed (increases with difficulty)
  double scrollSpeed = GameConstants.initialScrollSpeed;

  /// Game state flags
  bool isGameOver = false;
  bool isPaused = false;
  bool _isGameStarted = false;

  // ============ COMPONENTS ============
  /// The player character
  Player? player;

  /// List of active tile rows
  final List<TileRow> rows = [];

  /// Joystick for horizontal movement
  GameJoystick? joystick;

  /// Jump button
  JumpButton? jumpButton;

  // ============ GAME CONFIG ============
  /// Distance between rows (vertical spacing)
  double get rowSpacing =>
      GameConstants.rowSpacing + GameConstants.platformHeight;

  /// Current row index (for spawning new rows)
  int _nextRowIndex = 0;

  /// Random number generator for row generation
  final Random _random = Random();

  /// Y position where rows are removed (bottom of arena)
  late double _despawnY;

  /// Top boundary of the arena (below HUD)
  late double _arenaTop;

  /// Bottom boundary of the arena (above controls)
  late double _arenaBottom;

  /// Left boundary of the arena
  late double _arenaLeft;

  /// Right boundary of the arena
  late double _arenaRight;

  /// Public accessor for arena left bound (for player movement clamping)
  double get arenaLeft => _arenaLeft;

  /// Public accessor for arena right bound (for player movement clamping)
  double get arenaRight => _arenaRight;

  @override
  Color backgroundColor() => GameColors.background;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Calculate arena boundaries
    // Note: We don't have access to MediaQuery here, so we approximate safe area
    // The actual safe area padding will be handled by the Flutter overlay widgets
    const topSafeArea = 50.0; // Approximate safe area for status bar
    const bottomSafeArea = 20.0; // Approximate safe area for home indicator

    _arenaTop = topSafeArea + GameConstants.hudAreaHeight;
    _arenaBottom = size.y - GameConstants.controlsAreaHeight - bottomSafeArea;
    _arenaLeft = GameConstants.arenaPadding + GameConstants.arenaBorderWidth;
    _arenaRight =
        size.x - GameConstants.arenaPadding - GameConstants.arenaBorderWidth;

    // Set despawn position at bottom of arena
    _despawnY = _arenaBottom;

    // Don't initialize game components - wait for user to start the game
    debugPrint('OneSafeTileGame loaded - Screen: ${size.x}x${size.y}');
    debugPrint(
      'Arena bounds: top=$_arenaTop, bottom=$_arenaBottom, left=$_arenaLeft, right=$_arenaRight',
    );
  }

  /// Starts the game from the menu
  void startGame() {
    if (_isGameStarted) return;

    _isGameStarted = true;
    isGameOver = false;
    isPaused = false;
    score = 0;
    scoreNotifier.value = 0;
    scrollSpeed = GameConstants.initialScrollSpeed;
    _nextRowIndex = 0;

    // Initialize game components
    _initializeRows();
    _initializePlayer();
    _initializeHUD();

    // Switch overlays: hide menu, show HUD
    overlays.remove('menu');
    overlays.add('hud');

    debugPrint('Game started!');
  }

  /// Shows the main menu
  void showMenu() {
    _isGameStarted = false;
    isGameOver = false;
    isPaused = false;

    // Clean up game components
    _cleanupGame();

    // Switch overlays: hide game over, show menu
    overlays.remove('gameOver');
    overlays.remove('hud');
    overlays.add('menu');

    debugPrint('Menu shown');
  }

  /// Cleans up all game components for reset
  void _cleanupGame() {
    // Remove all rows
    for (final row in rows) {
      row.removeFromParent();
    }
    rows.clear();

    // Remove player
    player?.removeFromParent();
    player = null;

    // Remove HUD components
    joystick?.removeFromParent();
    joystick = null;
    jumpButton?.removeFromParent();
    jumpButton = null;
  }

  /// Creates initial rows on the screen
  void _initializeRows() {
    // Calculate how many rows fit in the arena
    final arenaHeight = _arenaBottom - _arenaTop;
    final numRows = (arenaHeight / rowSpacing).ceil() + 3;

    // Spawn initial rows from top to bottom
    for (int i = 0; i < numRows; i++) {
      final rowY = _arenaTop + (i * rowSpacing);
      _spawnRow(atY: rowY);
    }
  }

  /// Creates the player at starting position
  void _initializePlayer() {
    // Find a row that's in the lower portion of the arena but safely above despawn
    // We want to start on a row that's about 2/3 down the arena
    final arenaHeight = _arenaBottom - _arenaTop;
    final targetY = _arenaTop + (arenaHeight * 0.6);

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

    // Position player at center of arena horizontally, on the starting row
    final arenaCenterX = (_arenaLeft + _arenaRight) / 2;
    player = Player(
      position: Vector2(
        arenaCenterX,
        startRow.position.y + GameConstants.platformHeight / 2,
      ),
    );

    debugPrint(
      'Player starting at Y: ${player!.position.y}, despawnY: $_despawnY',
    );
    add(player!);
  }

  /// Creates the HUD (joystick and jump button)
  void _initializeHUD() {
    // Calculate controls Y position (center of controls area)
    final controlsAreaTop = size.y - GameConstants.controlsAreaHeight;
    final controlsCenterY =
        controlsAreaTop + (GameConstants.controlsAreaHeight / 2);

    // Position joystick in bottom-left of controls area
    joystick = GameJoystick(
      position: Vector2(
        GameConstants.controlsMargin + GameConstants.joystickSize / 2,
        controlsCenterY,
      ),
      onInputChanged: (input) {
        player?.setHorizontalInput(input);
      },
    );

    // Position jump button in bottom-right of controls area
    jumpButton = JumpButton(
      position: Vector2(
        size.x -
            GameConstants.controlsMargin -
            GameConstants.jumpButtonSize / 2,
        controlsCenterY,
      ),
      onPressed: _onJumpPressed,
    );

    // Add HUD components with high priority so they render on top
    add(joystick!);
    add(jumpButton!);
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
    final newestRow = rows.reduce(
      (a, b) => a.position.y < b.position.y ? a : b,
    );
    return newestRow.safeTileIndex;
  }

  /// Spawns a new row at the specified Y position
  void _spawnRow({required double atY}) {
    final arenaWidth = _arenaRight - _arenaLeft;
    final row = TileRow.algorithmic(
      rowIndex: _nextRowIndex++,
      position: Vector2(0, atY),
      arenaWidth: arenaWidth,
      arenaLeft: _arenaLeft,
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

    // Don't update if game hasn't started or is over/paused
    if (!_isGameStarted || isGameOver || isPaused) return;

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
    final currentPlayer = player;
    if (currentPlayer != null && !currentPlayer.isJumping) {
      currentPlayer.position.y += scrollDelta;
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
      final highestRow = rows.reduce(
        (a, b) => a.position.y < b.position.y ? a : b,
      );
      if (highestRow.position.y > _arenaTop + rowSpacing) {
        _spawnRow(atY: highestRow.position.y - rowSpacing);
      }
    }
  }

  /// Checks if player has fallen behind (scrolled off bottom)
  void _checkDeathByScroll() {
    final currentPlayer = player;
    if (currentPlayer != null && currentPlayer.position.y > _despawnY) {
      onPlayerDeath(reason: 'Fell behind!');
    }
  }

  /// Called when jump button is pressed
  void _onJumpPressed() {
    final currentPlayer = player;
    if (isGameOver ||
        isPaused ||
        currentPlayer == null ||
        currentPlayer.isJumping)
      return;

    // Simply initiate jump - physics will handle the rest
    currentPlayer.jump();
    debugPrint('Jump!');
  }

  /// Checks if the player has landed on a platform (called during falling)
  void checkPlayerLanding(double previousY) {
    final currentPlayer = player;
    if (currentPlayer == null) return;

    final playerBottom = currentPlayer.bottomY;

    // Check each row to see if player crossed through it
    for (final row in rows) {
      final platformTop = row.position.y;
      final platformBottom = row.position.y + GameConstants.platformHeight;

      // Check if player's bottom crossed the platform top (landing)
      // previousY bottom was above platform, current bottom is at or below platform top
      final prevBottom = previousY + currentPlayer.size.y / 2;

      if (prevBottom <= platformTop &&
          playerBottom >= platformTop &&
          playerBottom <= platformBottom + 10) {
        // Player landed on this platform!
        _handleLanding(row);
        return;
      }
    }
  }

  /// Handles the player landing on a specific row
  void _handleLanding(TileRow row) {
    final currentPlayer = player;
    if (currentPlayer == null) return;

    // Position player on top of the platform
    final landingY = row.position.y - currentPlayer.size.y / 2 + 2;
    currentPlayer.land(landingY);

    // Find which tile the player landed on
    final landedTile = row.getTileAtX(currentPlayer.position.x);
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
    scoreNotifier.value = score; // Update UI
    _updateDifficulty();
    debugPrint('Score: $score');
  }

  /// Called when player dies
  void onPlayerDeath({String reason = 'Game Over'}) {
    isGameOver = true;
    debugPrint('Game Over! Reason: $reason, Final score: $score');

    // Switch overlays: hide HUD, show game over
    overlays.remove('hud');
    overlays.add('gameOver');
  }

  /// Increases difficulty based on current score
  void _updateDifficulty() {
    if (score % GameConstants.difficultyIncreaseInterval == 0) {
      scrollSpeed = (scrollSpeed + GameConstants.speedIncrement).clamp(
        GameConstants.initialScrollSpeed,
        GameConstants.maxScrollSpeed,
      );
      debugPrint('Difficulty increased! Speed: $scrollSpeed');
    }
  }

  /// Resets the game to initial state
  void resetGame() {
    // Reset state
    score = 0;
    scoreNotifier.value = 0;
    scrollSpeed = GameConstants.initialScrollSpeed;
    isGameOver = false;
    isPaused = false;
    _isGameStarted = false;
    _nextRowIndex = 0;

    // Clean up all game components
    _cleanupGame();

    // Hide game over overlay
    overlays.remove('gameOver');
    overlays.remove('hud');

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
