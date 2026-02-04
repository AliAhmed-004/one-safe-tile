import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';

/// A component that can apply screen shake effects to the game camera.
///
/// Screen shake is used to provide impactful feedback for events like:
/// - Landing on a dangerous tile (death)
/// - Score milestones
/// - Near misses
class ScreenShaker extends Component {
  /// Whether shake is currently active
  bool _isShaking = false;

  /// Current shake intensity
  double _intensity = 0;

  /// Remaining shake duration
  double _duration = 0;

  /// Original camera position (to restore after shake)
  Vector2? _originalPosition;

  /// Random number generator for shake offsets
  final Random _random = Random();

  /// The camera component to shake
  CameraComponent? camera;

  @override
  void update(double dt) {
    super.update(dt);

    if (!_isShaking || camera == null) return;

    _duration -= dt;

    if (_duration <= 0) {
      // Shake finished, restore camera position
      _stopShake();
      return;
    }

    // Calculate shake offset with decreasing intensity
    final progress = _duration / _intensity; // Normalize
    final currentIntensity = _intensity * progress.clamp(0.0, 1.0);

    final offsetX = (_random.nextDouble() - 0.5) * 2 * currentIntensity;
    final offsetY = (_random.nextDouble() - 0.5) * 2 * currentIntensity;

    // Apply shake offset to camera viewport
    if (_originalPosition != null) {
      camera!.viewfinder.position =
          _originalPosition! + Vector2(offsetX, offsetY);
    }
  }

  /// Triggers a screen shake effect.
  ///
  /// [intensity] - Maximum pixel offset for the shake (default: 8)
  /// [duration] - How long the shake lasts in seconds (default: 0.3)
  void shake({double intensity = 8, double duration = 0.3}) {
    if (camera == null) return;

    // Store original position if not already shaking
    if (!_isShaking) {
      _originalPosition = camera!.viewfinder.position.clone();
    }

    _isShaking = true;
    _intensity = intensity;
    _duration = duration;
  }

  /// Triggers a light shake for minor events.
  void shakeLight() {
    shake(intensity: 4, duration: 0.15);
  }

  /// Triggers a medium shake for moderate impacts.
  void shakeMedium() {
    shake(intensity: 8, duration: 0.25);
  }

  /// Triggers a heavy shake for major events (like death).
  void shakeHeavy() {
    shake(intensity: 15, duration: 0.4);
  }

  void _stopShake() {
    _isShaking = false;
    if (_originalPosition != null && camera != null) {
      camera!.viewfinder.position = _originalPosition!;
    }
    _originalPosition = null;
  }

  /// Immediately stops any active shake.
  void stop() {
    _stopShake();
    _duration = 0;
  }
}

/// Extension to easily add shake effects to components with MoveEffect.
extension ShakeEffect on PositionComponent {
  /// Applies a shake effect to this component.
  void addShakeEffect({
    double intensity = 5,
    double duration = 0.3,
    int shakeCount = 6,
  }) {
    final originalPosition = position.clone();
    final random = Random();

    // Create a sequence of random offset movements
    final effects = <Effect>[];
    final shakeDuration = duration / shakeCount;

    for (int i = 0; i < shakeCount; i++) {
      // Decreasing intensity over time
      final progress = 1 - (i / shakeCount);
      final currentIntensity = intensity * progress;

      final offsetX = (random.nextDouble() - 0.5) * 2 * currentIntensity;
      final offsetY = (random.nextDouble() - 0.5) * 2 * currentIntensity;

      effects.add(
        MoveEffect.to(
          originalPosition + Vector2(offsetX, offsetY),
          EffectController(duration: shakeDuration),
        ),
      );
    }

    // Final move back to original position
    effects.add(
      MoveEffect.to(
        originalPosition,
        EffectController(duration: shakeDuration),
      ),
    );

    // Add all effects as a sequence
    add(SequenceEffect(effects));
  }
}
