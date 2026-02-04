import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/one_safe_tile_game.dart';
import '../utils/constants.dart';

/// The player character that jumps between tile rows.
///
/// The player can move horizontally using the joystick and jump
/// using the jump button. Physics-based movement with gravity.
class Player extends PositionComponent with HasGameRef<OneSafeTileGame> {
  /// Current horizontal velocity (from joystick input)
  double horizontalVelocity = 0;

  /// Current vertical velocity (affected by jump and gravity)
  double verticalVelocity = 0;

  /// Whether the player is currently in the air (jumping or falling)
  bool _isInAir = false;

  /// Base gravity acceleration (pixels per second squared)
  static const double _baseGravity = 1200.0;

  /// Base jump velocity (negative = upward)
  static const double _baseJumpVelocity = -500.0;

  /// Visual representation of the player
  late RectangleComponent _body;

  Player({required Vector2 position})
    : super(
        position: position,
        size: Vector2.all(GameConstants.playerSize),
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create player body
    _body = RectangleComponent(
      size: size,
      paint: Paint()..color = GameColors.player,
    );

    // Add white outline
    final outline = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = GameColors.playerOutline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    add(_body);
    add(outline);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameRef.isGameOver || gameRef.isPaused) return;

    // Always allow horizontal movement (even in air for control)
    _updateHorizontalMovement(dt);

    // Apply physics when in the air
    if (_isInAir) {
      _updatePhysics(dt);
    }
  }

  /// Updates horizontal position based on joystick input
  void _updateHorizontalMovement(double dt) {
    if (horizontalVelocity == 0) return;

    final newX = position.x + horizontalVelocity * dt;

    // Clamp to arena bounds (with some padding)
    final halfWidth = size.x / 2;
    final minX = gameRef.arenaLeft + halfWidth + GameConstants.tileSpacing;
    final maxX = gameRef.arenaRight - halfWidth - GameConstants.tileSpacing;

    position.x = newX.clamp(minX, maxX);
  }

  /// Updates physics (gravity and vertical movement)
  void _updatePhysics(double dt) {
    // Get current gravity and apply to vertical velocity
    // Gravity scales up slightly with game speed for snappier feel
    final speedMultiplier =
        1.0 + (gameRef.scrollSpeed / GameConstants.maxScrollSpeed) * 0.3;
    final gravity = _baseGravity * speedMultiplier;

    verticalVelocity += gravity * dt;

    // Update position
    final previousY = position.y;
    position.y += verticalVelocity * dt;

    // Emit jump trail particles occasionally
    if (gameRef.particleEmitter != null) {
      // Emit trail particles at ~20fps
      _trailTimer += dt;
      if (_trailTimer >= 0.05) {
        _trailTimer = 0;
        gameRef.particleEmitter!.emitJumpTrail(position);
      }
    }

    // Check for landing on a platform (only when falling down)
    if (verticalVelocity > 0) {
      gameRef.checkPlayerLanding(previousY);
    }
  }

  /// Timer for jump trail particle emission
  double _trailTimer = 0;

  /// Initiates a jump
  void jump() {
    if (_isInAir) return;

    _isInAir = true;
    // Jump velocity scales up slightly with game speed
    final speedMultiplier =
        1.0 + (gameRef.scrollSpeed / GameConstants.maxScrollSpeed) * 0.3;
    verticalVelocity = _baseJumpVelocity * speedMultiplier;
  }

  /// Called when player lands on a platform
  void land(double platformY) {
    _isInAir = false;
    verticalVelocity = 0;
    horizontalVelocity = 0; // Stop horizontal movement on landing
    // Position player on top of the platform
    position.y = platformY;
  }

  /// Sets horizontal velocity from joystick input (-1 to 1)
  void setHorizontalInput(double input) {
    horizontalVelocity = input * GameConstants.playerMoveSpeed;
  }

  /// Stops horizontal movement
  void stopHorizontalMovement() {
    horizontalVelocity = 0;
  }

  /// Returns whether the player is currently in the air
  bool get isJumping => _isInAir;

  /// Gets the player's bottom Y position (for collision detection)
  double get bottomY => position.y + size.y / 2;

  /// Gets the player's top Y position
  double get topY => position.y - size.y / 2;
}
