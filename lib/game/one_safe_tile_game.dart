import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Main game class for One Safe Tile.
/// 
/// This is the central FlameGame instance that manages:
/// - Game world and components
/// - Game state (playing, paused, game over)
/// - Score tracking
/// - Difficulty scaling
class OneSafeTileGame extends FlameGame {
  // Current player score
  int score = 0;

  // Current scroll speed (increases with difficulty)
  double scrollSpeed = 100.0;

  // Game state
  bool isGameOver = false;
  bool isPaused = false;

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // TODO: Initialize game components (player, rows, HUD)
    debugPrint('OneSafeTileGame loaded');
  }

  @override
  void update(double dt) {
    if (isGameOver || isPaused) return;
    super.update(dt);
    // TODO: Update scroll position, spawn rows, check death conditions
  }

  /// Resets the game to initial state
  void resetGame() {
    score = 0;
    scrollSpeed = 100.0;
    isGameOver = false;
    isPaused = false;
    // TODO: Reset all components
    debugPrint('Game reset');
  }

  /// Called when player successfully lands on a safe tile
  void onSuccessfulJump() {
    score++;
    _updateDifficulty();
    debugPrint('Score: $score');
  }

  /// Called when player dies (wrong tile or fell behind)
  void onPlayerDeath() {
    isGameOver = true;
    // TODO: Show game over overlay
    debugPrint('Game Over! Final score: $score');
  }

  /// Increases difficulty based on current score
  void _updateDifficulty() {
    // Increase scroll speed every 5 points
    if (score % 5 == 0) {
      scrollSpeed += 10.0;
      debugPrint('Difficulty increased! Speed: $scrollSpeed');
    }
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
