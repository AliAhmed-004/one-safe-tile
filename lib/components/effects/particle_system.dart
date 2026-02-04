import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../utils/constants.dart';

/// A single particle used in particle effects.
class Particle {
  Vector2 position;
  Vector2 velocity;
  double life;
  double maxLife;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;

  Particle({
    required this.position,
    required this.velocity,
    required this.life,
    required this.color,
    required this.size,
    this.rotation = 0,
    this.rotationSpeed = 0,
  }) : maxLife = life;

  /// Returns the current opacity based on remaining life (fades out)
  double get opacity => (life / maxLife).clamp(0.0, 1.0);

  /// Updates the particle physics and lifetime
  void update(double dt) {
    position += velocity * dt;
    life -= dt;
    rotation += rotationSpeed * dt;
  }

  /// Whether the particle is still alive
  bool get isAlive => life > 0;
}

/// Types of particle effects available in the game.
enum ParticleEffectType {
  /// Green sparkle effect when landing on safe tile
  safeLanding,

  /// Red explosion effect when landing on dangerous tile
  dangerLanding,

  /// Celebratory burst for score milestones
  scoreMilestone,

  /// Trail effect while player is jumping
  jumpTrail,
}

/// A particle emitter that creates and manages particle effects.
class ParticleEmitter extends Component {
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void update(double dt) {
    super.update(dt);

    // Update all particles
    for (final particle in _particles) {
      particle.update(dt);
    }

    // Remove dead particles
    _particles.removeWhere((p) => !p.isAlive);
  }

  @override
  void render(Canvas canvas) {
    for (final particle in _particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity);

      canvas.save();
      canvas.translate(particle.position.x, particle.position.y);
      canvas.rotate(particle.rotation);

      // Draw particle as a small square/diamond
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  /// Emits particles for a safe landing effect.
  /// Creates green sparkles that burst upward.
  void emitSafeLanding(Vector2 position) {
    const particleCount = 12;
    final baseColor = GameColors.safeTileHighlight;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi + _random.nextDouble() * 0.3;
      final speed = 80 + _random.nextDouble() * 60;

      _particles.add(
        Particle(
          position: position.clone(),
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed - 50),
          life: 0.4 + _random.nextDouble() * 0.3,
          color: baseColor.withOpacity(0.8 + _random.nextDouble() * 0.2),
          size: 4 + _random.nextDouble() * 4,
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 8,
        ),
      );
    }
  }

  /// Emits particles for a dangerous landing (death) effect.
  /// Creates red/orange explosion particles.
  void emitDangerLanding(Vector2 position) {
    const particleCount = 25;

    for (int i = 0; i < particleCount; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 100 + _random.nextDouble() * 150;

      // Mix of red and orange particles
      final colorChoice = _random.nextDouble();
      Color color;
      if (colorChoice < 0.5) {
        color = GameColors.dangerousTileHighlight;
      } else if (colorChoice < 0.8) {
        color = const Color(0xFFFF8800); // Orange
      } else {
        color = const Color(0xFFFFCC00); // Yellow
      }

      _particles.add(
        Particle(
          position: position.clone(),
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
          life: 0.5 + _random.nextDouble() * 0.4,
          color: color,
          size: 5 + _random.nextDouble() * 6,
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 12,
        ),
      );
    }
  }

  /// Emits particles for score milestone celebration.
  void emitScoreMilestone(Vector2 position) {
    const particleCount = 20;
    final colors = [
      GameColors.safeTileHighlight,
      const Color(0xFFFFD700), // Gold
      const Color(0xFF00BFFF), // Sky blue
      GameColors.player,
    ];

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi;
      final speed = 120 + _random.nextDouble() * 80;

      _particles.add(
        Particle(
          position: position.clone(),
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed - 30),
          life: 0.6 + _random.nextDouble() * 0.4,
          color: colors[_random.nextInt(colors.length)],
          size: 5 + _random.nextDouble() * 5,
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        ),
      );
    }
  }

  /// Emits a small trail particle behind the player while jumping.
  void emitJumpTrail(Vector2 position) {
    _particles.add(
      Particle(
        position: position.clone(),
        velocity: Vector2(
          (_random.nextDouble() - 0.5) * 20,
          _random.nextDouble() * 30,
        ),
        life: 0.2 + _random.nextDouble() * 0.15,
        color: GameColors.player.withOpacity(0.6),
        size: 3 + _random.nextDouble() * 3,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: 0,
      ),
    );
  }

  /// Clears all active particles.
  void clear() {
    _particles.clear();
  }
}
