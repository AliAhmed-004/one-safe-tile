import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';

/// Tracks and displays the player's combo/streak for consecutive safe landings.
///
/// Features:
/// - Shows current streak count with animated text
/// - Displays streak multiplier for bonus scoring
/// - Visual feedback for streak milestones (5, 10, 15, etc.)
class ComboTracker extends PositionComponent {
  /// Current consecutive safe landings
  int _currentStreak = 0;

  /// Best streak this game
  int _bestStreak = 0;

  /// Whether to show the combo display
  bool _isVisible = false;

  /// Animation timer for the combo text
  double _animationTimer = 0;

  /// Scale for pop animation
  double _scale = 1.0;

  /// Opacity for fade effect
  double _opacity = 1.0;

  /// Callbacks for streak milestones
  void Function(int milestone)? onMilestone;

  ComboTracker({this.onMilestone});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isVisible) return;

    _animationTimer += dt;

    // Pop animation on new streak
    if (_scale > 1.0) {
      _scale = 1.0 + (_scale - 1.0) * 0.9; // Decay towards 1.0
      if (_scale < 1.02) _scale = 1.0;
    }

    // Fade out after a delay
    if (_animationTimer > 2.0) {
      _opacity -= dt * 2;
      if (_opacity <= 0) {
        _isVisible = false;
        _opacity = 1.0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_isVisible || _currentStreak < 2) return;

    canvas.save();

    // Apply scale and opacity
    final centerX = size.x / 2;
    final centerY = size.y / 2;
    canvas.translate(centerX, centerY);
    canvas.scale(_scale);
    canvas.translate(-centerX, -centerY);

    // Draw streak count
    final streakText = '${_currentStreak}x';
    final streakPaint = TextPaint(
      style: TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 28,
        color: _getStreakColor().withOpacity(_opacity),
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: const Offset(2, 2),
            blurRadius: 4,
            color: Colors.black.withOpacity(_opacity * 0.5),
          ),
        ],
      ),
    );

    streakPaint.render(
      canvas,
      streakText,
      Vector2(size.x / 2, size.y / 2 - 15),
      anchor: Anchor.center,
    );

    // Draw "COMBO" label
    final labelPaint = TextPaint(
      style: TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 10,
        color: GameColors.textSecondary.withOpacity(_opacity * 0.8),
        fontWeight: FontWeight.bold,
      ),
    );

    labelPaint.render(
      canvas,
      'COMBO',
      Vector2(size.x / 2, size.y / 2 + 15),
      anchor: Anchor.center,
    );

    // Draw bonus text for high streaks
    if (_currentStreak >= 5) {
      final bonusText = '+${getScoreMultiplier() * 100 - 100}% BONUS';
      final bonusPaint = TextPaint(
        style: TextStyle(
          fontFamily: 'PressStart2P',
          fontSize: 8,
          color: GameColors.safeTileHighlight.withOpacity(_opacity * 0.7),
        ),
      );

      bonusPaint.render(
        canvas,
        bonusText,
        Vector2(size.x / 2, size.y / 2 + 30),
        anchor: Anchor.center,
      );
    }

    canvas.restore();
  }

  /// Gets the color based on streak level
  Color _getStreakColor() {
    if (_currentStreak >= 15) {
      return const Color(0xFFFFD700); // Gold
    } else if (_currentStreak >= 10) {
      return const Color(0xFFFF6B6B); // Coral/Orange-red
    } else if (_currentStreak >= 5) {
      return GameColors.safeTileHighlight;
    } else {
      return GameColors.textPrimary;
    }
  }

  /// Increments the streak on a safe landing.
  void incrementStreak() {
    _currentStreak++;
    if (_currentStreak > _bestStreak) {
      _bestStreak = _currentStreak;
    }

    // Show combo display
    _isVisible = true;
    _animationTimer = 0;
    _opacity = 1.0;
    _scale = 1.3; // Pop effect

    // Check for milestones (every 5)
    if (_currentStreak % 5 == 0 && _currentStreak > 0) {
      onMilestone?.call(_currentStreak);
      _scale = 1.5; // Bigger pop for milestones
    }
  }

  /// Resets the streak (on death or missed landing).
  void resetStreak() {
    _currentStreak = 0;
    _isVisible = false;
    _animationTimer = 0;
  }

  /// Gets the current score multiplier based on streak.
  /// - 0-4 streak: 1.0x
  /// - 5-9 streak: 1.1x
  /// - 10-14 streak: 1.2x
  /// - 15+ streak: 1.5x
  double getScoreMultiplier() {
    if (_currentStreak >= 15) return 1.5;
    if (_currentStreak >= 10) return 1.2;
    if (_currentStreak >= 5) return 1.1;
    return 1.0;
  }

  /// Current streak count
  int get currentStreak => _currentStreak;

  /// Best streak this game
  int get bestStreak => _bestStreak;

  /// Resets all stats for a new game
  void reset() {
    _currentStreak = 0;
    _bestStreak = 0;
    _isVisible = false;
    _animationTimer = 0;
    _opacity = 1.0;
    _scale = 1.0;
  }
}
