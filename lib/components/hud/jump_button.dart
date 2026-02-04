import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';

/// A button for triggering player jumps.
/// 
/// Positioned in the bottom-right corner of the screen.
class JumpButton extends PositionComponent with TapCallbacks {
  /// Visual button component
  late CircleComponent _button;

  /// Button label
  late TextComponent _label;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Whether the button is currently pressed
  bool _isPressed = false;

  JumpButton({
    required Vector2 position,
    this.onPressed,
  }) : super(
          position: position,
          size: Vector2.all(GameConstants.jumpButtonSize),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final buttonRadius = GameConstants.jumpButtonSize / 2;

    // Create button circle
    _button = CircleComponent(
      radius: buttonRadius,
      position: Vector2(buttonRadius, buttonRadius),
      anchor: Anchor.center,
      paint: Paint()..color = GameColors.jumpButton,
    );

    // Create label
    _label = TextComponent(
      text: 'JUMP',
      position: Vector2(buttonRadius, buttonRadius),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(_button);
    add(_label);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _isPressed = true;
    _button.paint.color = GameColors.jumpButton.withOpacity(0.7);
    onPressed?.call();
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    _resetButton();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    super.onTapCancel(event);
    _resetButton();
  }

  /// Resets button to default state
  void _resetButton() {
    _isPressed = false;
    _button.paint.color = GameColors.jumpButton;
  }

  /// Whether the button is currently pressed
  bool get isPressed => _isPressed;

  @override
  bool containsLocalPoint(Vector2 point) {
    // Expand hit area for easier touch
    final center = Vector2.all(GameConstants.jumpButtonSize / 2);
    final distance = point.distanceTo(center);
    return distance <= GameConstants.jumpButtonSize / 2 + 20;
  }
}

