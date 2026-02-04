import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/score_manager.dart';

/// Main menu screen shown when the game starts.
/// Displays title, high score, and play button.
class MenuScreen extends StatelessWidget {
  final VoidCallback onPlayPressed;

  const MenuScreen({
    super.key,
    required this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final highScore = ScoreManager.instance.getHighScore();

    return Container(
      color: GameColors.background.withValues(alpha: 0.95),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Game Title
              const Text(
                'ONE SAFE',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: GameColors.textPrimary,
                  letterSpacing: 4,
                  height: 1.0,
                ),
              ),
              const Text(
                'TILE',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: GameColors.buttonPrimary,
                  letterSpacing: 8,
                  height: 1.0,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Subtitle
              Text(
                'Jump. Land. Survive.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: GameColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
              
              const Spacer(flex: 1),
              
              // High Score
              if (highScore > 0) ...[
                Text(
                  'HIGH SCORE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: GameColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$highScore',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: GameColors.safeTileHighlight,
                  ),
                ),
                const SizedBox(height: 40),
              ],
              
              // Play Button
              _PlayButton(onPressed: onPlayPressed),
              
              const Spacer(flex: 2),
              
              // Instructions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Use joystick to move • Tap jump to leap\nLand on the safe tile to survive',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: GameColors.textSecondary.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated play button
class _PlayButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _PlayButton({required this.onPressed});

  @override
  State<_PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<_PlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
          decoration: BoxDecoration(
            color: GameColors.buttonPrimary,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: GameColors.buttonPrimary.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Text(
            'PLAY',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }
}
