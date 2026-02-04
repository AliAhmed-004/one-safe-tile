import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Pause overlay shown when the game is paused.
/// Displays resume and quit options.
class PauseOverlay extends StatelessWidget {
  final VoidCallback onResumePressed;
  final VoidCallback onQuitPressed;

  const PauseOverlay({
    super.key,
    required this.onResumePressed,
    required this.onQuitPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameColors.background.withOpacity(0.85),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pause icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: GameColors.buttonSecondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: GameColors.arenaBorder, width: 2),
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  color: GameColors.textPrimary,
                  size: 48,
                ),
              ),

              const SizedBox(height: 24),

              // Paused text
              const Text(
                'PAUSED',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: GameColors.textPrimary,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 48),

              // Resume button
              _PauseButton(
                text: 'RESUME',
                icon: Icons.play_arrow_rounded,
                color: GameColors.buttonPrimary,
                onPressed: onResumePressed,
              ),

              const SizedBox(height: 16),

              // Quit button
              _PauseButton(
                text: 'QUIT',
                icon: Icons.exit_to_app_rounded,
                color: GameColors.buttonSecondary,
                onPressed: onQuitPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Button used in pause menu
class _PauseButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _PauseButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: GameColors.arenaBorder.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: GameColors.textPrimary, size: 24),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: GameColors.textPrimary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
