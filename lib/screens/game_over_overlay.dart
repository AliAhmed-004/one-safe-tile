import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/score_manager.dart';

/// Game over overlay shown when the player dies.
/// Displays final score, high score, and restart button.
class GameOverOverlay extends StatefulWidget {
  final int score;
  final VoidCallback onRestartPressed;
  final VoidCallback onMenuPressed;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.onRestartPressed,
    required this.onMenuPressed,
  });

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isNewHighScore = false;
  int _highScore = 0;

  @override
  void initState() {
    super.initState();

    // Check and update high score
    _highScore = ScoreManager.instance.getHighScore();
    if (widget.score > _highScore) {
      _isNewHighScore = true;
      _highScore = widget.score;
      ScoreManager.instance.updateHighScore(widget.score);
    }

    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: GameColors.background.withOpacity(0.9),
        child: SafeArea(
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Game Over Title
                  const Text(
                    'GAME OVER',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: GameColors.dangerousTileHighlight,
                      letterSpacing: 4,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Score Section
                  Text(
                    'SCORE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: GameColors.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.score}',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w800,
                      color: GameColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // New High Score Badge or High Score Display
                  if (_isNewHighScore)
                    _NewHighScoreBadge()
                  else ...[
                    Text(
                      'HIGH SCORE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: GameColors.textSecondary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_highScore',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: GameColors.safeTileHighlight,
                      ),
                    ),
                  ],

                  const Spacer(flex: 1),

                  // Restart Button
                  _ActionButton(
                    text: 'PLAY AGAIN',
                    color: GameColors.buttonPrimary,
                    onPressed: widget.onRestartPressed,
                  ),

                  const SizedBox(height: 16),

                  // Menu Button
                  _ActionButton(
                    text: 'MENU',
                    color: GameColors.buttonSecondary,
                    onPressed: widget.onMenuPressed,
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// New high score celebration badge
class _NewHighScoreBadge extends StatefulWidget {
  @override
  State<_NewHighScoreBadge> createState() => _NewHighScoreBadgeState();
}

class _NewHighScoreBadgeState extends State<_NewHighScoreBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: GameColors.safeTileHighlight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: GameColors.safeTileHighlight.withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Text(
          '🎉 NEW HIGH SCORE! 🎉',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: GameColors.background,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

/// Reusable action button
class _ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
