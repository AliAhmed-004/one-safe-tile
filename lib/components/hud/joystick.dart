import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../game/one_safe_tile_game.dart';
import '../../utils/constants.dart';

/// A fixed joystick for horizontal player movement.
/// 
/// Positioned in the bottom-left corner of the screen.
/// Only provides left/right input (no vertical movement).
class GameJoystick extends PositionComponent
    with DragCallbacks, HasGameRef<OneSafeTileGame> {
  /// Outer circle (background)
  late CircleComponent _background;

  /// Inner circle (knob)
  late CircleComponent _knob;

  /// Knob rest position (center of joystick)
  late Vector2 _knobRestPosition;

  /// Maximum distance the knob can move from center
  late double _maxKnobDistance;

  /// Current horizontal input value (-1 to 1)
  double _horizontalInput = 0;

  /// Callback when input changes
  final void Function(double horizontalInput)? onInputChanged;

  GameJoystick({
    required Vector2 position,
    this.onInputChanged,
  }) : super(
          position: position,
          size: Vector2.all(GameConstants.joystickSize),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final joystickRadius = GameConstants.joystickSize / 2;
    final knobRadius = joystickRadius * 0.4;
    _maxKnobDistance = joystickRadius - knobRadius;

    // Create background circle
    _background = CircleComponent(
      radius: joystickRadius,
      position: Vector2(joystickRadius, joystickRadius),
      anchor: Anchor.center,
      paint: Paint()..color = GameColors.joystickBackground,
    );

    // Create knob
    _knobRestPosition = Vector2(joystickRadius, joystickRadius);
    _knob = CircleComponent(
      radius: knobRadius,
      position: _knobRestPosition.clone(),
      anchor: Anchor.center,
      paint: Paint()..color = GameColors.joystickKnob,
    );

    add(_background);
    add(_knob);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _updateKnobPosition(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    _updateKnobPosition(event.localEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _resetKnob();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _resetKnob();
  }

  /// Updates knob position based on touch location
  void _updateKnobPosition(Vector2 touchPosition) {
    // Calculate offset from center
    final offset = touchPosition - _knobRestPosition;

    // Only use horizontal component (we don't need vertical)
    final horizontalOffset = offset.x.clamp(-_maxKnobDistance, _maxKnobDistance);

    // Update knob position (only horizontal)
    _knob.position = Vector2(
      _knobRestPosition.x + horizontalOffset,
      _knobRestPosition.y,
    );

    // Calculate input value (-1 to 1)
    _horizontalInput = horizontalOffset / _maxKnobDistance;

    // Notify callback
    onInputChanged?.call(_horizontalInput);
  }

  /// Resets knob to center position
  void _resetKnob() {
    _knob.position = _knobRestPosition.clone();
    _horizontalInput = 0;
    onInputChanged?.call(0);
  }

  /// Gets current horizontal input (-1 to 1)
  double get horizontalInput => _horizontalInput;

  @override
  bool containsLocalPoint(Vector2 point) {
    // Expand hit area slightly for easier touch
    final center = Vector2.all(GameConstants.joystickSize / 2);
    final distance = point.distanceTo(center);
    return distance <= GameConstants.joystickSize / 2 + 20;
  }
}

