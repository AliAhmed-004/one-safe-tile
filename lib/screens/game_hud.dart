import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// In-game HUD overlay showing current score and pause button.
/// This sits at the top of the screen, above the arena.
class GameHud extends StatelessWidget {
  final int score;
  final VoidCallback onPausePressed;

  const GameHud({super.key, required this.score, required this.onPausePressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: GameConstants.hudAreaHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          color: GameColors.hudBackground,
          border: Border(
            bottom: BorderSide(color: GameColors.arenaBorder, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Score display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: GameColors.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: GameColors.arenaBorder.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: GameColors.safeTileHighlight,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: GameColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Pause button
            GestureDetector(
              onTap: onPausePressed,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: GameColors.buttonSecondary.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: GameColors.arenaBorder.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  color: GameColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
