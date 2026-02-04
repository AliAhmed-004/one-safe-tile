import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../game/one_safe_tile_game.dart';
import '../../utils/constants.dart';

/// One-hand controls using Angry Birds style "aim and release" mechanic.
///
/// - Touch and hold anywhere to start aiming
/// - Drag to aim - shows trajectory preview
/// - Release to jump in the aimed direction
class OneHandControls extends PositionComponent
    with HasGameRef<OneSafeTileGame>, DragCallbacks {
  /// Callback when jump is triggered with horizontal velocity
  final void Function(double horizontalVelocity) onAimRelease;

  /// Whether the player is currently aiming
  bool _isAiming = false;

  /// Starting position of the aim drag (in screen coordinates)
  Vector2? _aimStart;

  /// Current aim position (in screen coordinates)
  Vector2? _aimCurrent;



  /// Paint for the trajectory dots
  late Paint _trajectoryDotPaint;
  late Paint _targetPaint;

  OneHandControls({
    required Vector2 position,
    required Vector2 size,
    required this.onAimRelease,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Paint for trajectory dots
    _trajectoryDotPaint = Paint()
      ..color = GameColors.safeTileHighlight.withOpacity(0.8);

    // Target indicator paint
    _targetPaint = Paint()
      ..color = GameColors.safeTileHighlight.withOpacity(0.4)
      ..style = PaintingStyle.fill;
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // Respond to touches anywhere on this component
    return point.x >= 0 &&
        point.x <= size.x &&
        point.y >= 0 &&
        point.y <= size.y;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    // Don't allow aiming if player is already jumping
    final player = gameRef.player;
    if (player == null || player.isJumping) return;

    _isAiming = true;
    _aimStart = event.localPosition;
    _aimCurrent = event.localPosition;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_isAiming || _aimStart == null) return;
    _aimCurrent = event.localEndPosition;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    if (_isAiming && _aimStart != null && _aimCurrent != null) {
      _executeJump();
    }

    _resetAim();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _resetAim();
  }

  void _resetAim() {
    _isAiming = false;
    _aimStart = null;
    _aimCurrent = null;
  }

  void _executeJump() {
    if (_aimStart == null || _aimCurrent == null) return;

    // Calculate aim vector (from current back to start = direction to jump)
    // Inverted: drag left = jump right, drag down = jump up (like pulling back a slingshot)
    final aimDelta = _aimStart! - _aimCurrent!;

    // Calculate horizontal velocity based on horizontal aim component
    // Clamp the delta to max aim distance
    final clampedDeltaX =
        aimDelta.x.clamp(-GameConstants.aimMaxDistance, GameConstants.aimMaxDistance);

    // Convert to velocity (-1 to 1 range, then multiply by move speed)
    final normalizedX = clampedDeltaX / GameConstants.aimMaxDistance;
    final horizontalVelocity =
        normalizedX * GameConstants.playerMoveSpeed * GameConstants.aimSensitivity;

    onAimRelease(horizontalVelocity);
  }

  /// Gets the predicted landing position for trajectory visualization
  Vector2? _getPredictedLanding() {
    if (!_isAiming || _aimStart == null || _aimCurrent == null) return null;

    final player = gameRef.player;
    if (player == null) return null;

    // Calculate aim direction (inverted slingshot style)
    final aimDelta = _aimStart! - _aimCurrent!;
    final clampedDeltaX =
        aimDelta.x.clamp(-GameConstants.aimMaxDistance, GameConstants.aimMaxDistance);
    final normalizedX = clampedDeltaX / GameConstants.aimMaxDistance;

    // Simulate the jump trajectory to find landing position
    final horizontalVelocity =
        normalizedX * GameConstants.playerMoveSpeed * GameConstants.aimSensitivity;

    // Physics simulation
    final speedMultiplier =
        1.0 + (gameRef.scrollSpeed / GameConstants.maxScrollSpeed) * 0.3;
    final gravity = 1200.0 * speedMultiplier;
    final jumpVelocity = -500.0 * speedMultiplier;

    // Simulate until we reach approximately the same Y level (one row up)
    // Time to reach peak: t = -v0 / g
    // Time to land at same level: t = 2 * (-v0 / g)
    final timeToLand = 2 * (-jumpVelocity / gravity);

    // Calculate horizontal displacement
    final horizontalDisplacement = horizontalVelocity * timeToLand;

    // Predicted landing X position (clamped to arena)
    final predictedX = (player.position.x + horizontalDisplacement).clamp(
      gameRef.arenaLeft + player.size.x / 2,
      gameRef.arenaRight - player.size.x / 2,
    );

    // The Y position will be roughly one row up (accounting for scroll)
    // For visualization, we show it at the same level
    final predictedY = player.position.y - gameRef.rowSpacing;

    return Vector2(predictedX, predictedY);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (!_isAiming || _aimStart == null || _aimCurrent == null) return;

    final player = gameRef.player;
    if (player == null || player.isJumping) return;

    // Get player position in local coordinates
    final playerScreenPos = Vector2(
      player.position.x - position.x,
      player.position.y - position.y,
    );

    // Get predicted landing position
    final predictedLanding = _getPredictedLanding();
    if (predictedLanding == null) return;

    final targetScreenPos = Vector2(
      predictedLanding.x - position.x,
      predictedLanding.y - position.y,
    );

    // Draw trajectory arc using dots
    _drawTrajectoryArc(canvas, playerScreenPos, targetScreenPos);

    // Draw target indicator
    _drawTargetIndicator(canvas, targetScreenPos);

    // Draw aim indicator at touch point
    _drawAimIndicator(canvas);
  }

  void _drawTrajectoryArc(Canvas canvas, Vector2 start, Vector2 end) {
    // Draw a parabolic arc from player to target
    const numDots = 12;
    final dx = end.x - start.x;
    final dy = end.y - start.y;

    // Arc height (peak of the jump)
    final arcHeight = -80.0; // Negative because Y is inverted

    for (int i = 1; i <= numDots; i++) {
      final t = i / numDots;

      // Parabolic interpolation
      final x = start.x + dx * t;
      // Quadratic bezier-like arc: y = start + t*(end-start) + 4*h*t*(1-t)
      final y = start.y + dy * t + 4 * arcHeight * t * (1 - t);

      // Dots get smaller as they go further
      final dotRadius = 4.0 * (1.0 - t * 0.5);

      canvas.drawCircle(Offset(x, y), dotRadius, _trajectoryDotPaint);
    }
  }

  void _drawTargetIndicator(Canvas canvas, Vector2 target) {
    // Draw a crosshair/target at the predicted landing spot
    const targetSize = 24.0;

    // Outer circle
    canvas.drawCircle(Offset(target.x, target.y), targetSize / 2, _targetPaint);

    // Inner crosshair
    final crossPaint = Paint()
      ..color = GameColors.safeTileHighlight
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(target.x - targetSize / 2, target.y),
      Offset(target.x + targetSize / 2, target.y),
      crossPaint,
    );
    canvas.drawLine(
      Offset(target.x, target.y - targetSize / 2),
      Offset(target.x, target.y + targetSize / 2),
      crossPaint,
    );
  }

  void _drawAimIndicator(Canvas canvas) {
    if (_aimStart == null || _aimCurrent == null) return;

    // Draw a line from aim start to current position
    final aimPaint = Paint()
      ..color = GameColors.textSecondary.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(_aimStart!.x, _aimStart!.y),
      Offset(_aimCurrent!.x, _aimCurrent!.y),
      aimPaint,
    );

    // Draw a small circle at the touch point
    canvas.drawCircle(
      Offset(_aimCurrent!.x, _aimCurrent!.y),
      8,
      Paint()..color = GameColors.textSecondary.withOpacity(0.3),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // No continuous updates needed
  }
}

/// Visual hint overlay for one-hand controls
/// Shows aim instructions briefly when game starts
class OneHandControlsHint extends PositionComponent
    with HasGameRef<OneSafeTileGame> {
  double _opacity = 1.0;
  double _timer = 0;
  static const double _displayDuration = 2.5;
  static const double _fadeDuration = 0.5;

  OneHandControlsHint({required Vector2 position, required Vector2 size})
    : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;

    if (_timer > _displayDuration) {
      _opacity = 1.0 - ((_timer - _displayDuration) / _fadeDuration);
      _opacity = _opacity.clamp(0.0, 1.0);

      if (_opacity <= 0) {
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'HOLD & DRAG TO AIM • RELEASE TO JUMP',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: GameColors.textSecondary.withOpacity(_opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }
}
