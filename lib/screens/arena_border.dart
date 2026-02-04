import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Visual border overlay for the arena area.
/// Shows a bordered rectangle around the gameplay area.
class ArenaBorder extends StatelessWidget {
  const ArenaBorder({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    // Calculate arena bounds
    final arenaTop = topPadding + GameConstants.hudAreaHeight;
    final arenaBottom =
        GameConstants.controlsAreaHeight + mediaQuery.padding.bottom;

    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          margin: EdgeInsets.only(
            top: arenaTop,
            bottom: arenaBottom,
            left: GameConstants.arenaPadding,
            right: GameConstants.arenaPadding,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: GameColors.arenaBorder,
              width: GameConstants.arenaBorderWidth,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
