import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Controls panel overlay at the bottom of the screen.
/// This provides a visual container for the joystick and jump button
/// that are rendered by the Flame game.
/// 
/// Uses IgnorePointer so touch events pass through to Flame controls.
class ControlsPanel extends StatelessWidget {
  const ControlsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: IgnorePointer(
          child: Container(
            height: GameConstants.controlsAreaHeight,
            decoration: BoxDecoration(
              // Use a semi-transparent gradient so controls are visible
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  GameColors.controlsBackground.withOpacity(0.3),
                  GameColors.controlsBackground.withOpacity(0.8),
                ],
              ),
              border: const Border(
                top: BorderSide(color: GameColors.arenaBorder, width: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
