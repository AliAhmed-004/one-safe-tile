import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/settings_manager.dart';

/// Settings screen for game configuration.
/// Allows users to switch between control modes.
class SettingsScreen extends StatefulWidget {
  final VoidCallback onBackPressed;

  const SettingsScreen({super.key, required this.onBackPressed});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ControlMode _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = SettingsManager.instance.getControlMode();
  }

  void _setControlMode(ControlMode mode) {
    setState(() {
      _currentMode = mode;
    });
    SettingsManager.instance.setControlMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameColors.background.withOpacity(0.95),
      child: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBackPressed,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: GameColors.buttonSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: GameColors.arenaBorder.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: GameColors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'SETTINGS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: GameColors.textPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: GameColors.arenaBorder, height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Control Mode Section
                  const Text(
                    'CONTROL MODE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: GameColors.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Two-Hand Option
                  _ControlModeOption(
                    title: 'Two-Hand',
                    description: 'Joystick to move + Button to jump',
                    icon: Icons.gamepad_outlined,
                    isSelected: _currentMode == ControlMode.twoHand,
                    onTap: () => _setControlMode(ControlMode.twoHand),
                  ),

                  const SizedBox(height: 12),

                  // One-Hand Option
                  _ControlModeOption(
                    title: 'One-Hand',
                    description: 'Aim & release to jump (like Angry Birds)',
                    icon: Icons.touch_app_outlined,
                    isSelected: _currentMode == ControlMode.oneHand,
                    onTap: () => _setControlMode(ControlMode.oneHand),
                  ),

                  const SizedBox(height: 32),

                  // Control hints
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GameColors.buttonSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: GameColors.arenaBorder.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: GameColors.textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currentMode == ControlMode.oneHand
                                  ? 'One-Hand Controls'
                                  : 'Two-Hand Controls',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: GameColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_currentMode == ControlMode.oneHand) ...[
                          _HintRow(
                            icon: Icons.touch_app,
                            text: 'Hold anywhere to aim',
                          ),
                          const SizedBox(height: 8),
                          _HintRow(
                            icon: Icons.swipe,
                            text: 'Drag to set direction',
                          ),
                          const SizedBox(height: 8),
                          _HintRow(
                            icon: Icons.open_in_new,
                            text: 'Release to jump',
                          ),
                        ] else ...[
                          _HintRow(
                            icon: Icons.radio_button_checked,
                            text: 'Use joystick (left) to move',
                          ),
                          const SizedBox(height: 8),
                          _HintRow(
                            icon: Icons.arrow_circle_up,
                            text: 'Tap jump button (right) to jump',
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A selectable control mode option card
class _ControlModeOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ControlModeOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? GameColors.buttonPrimary.withOpacity(0.2)
              : GameColors.buttonSecondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? GameColors.buttonPrimary
                : GameColors.arenaBorder.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? GameColors.buttonPrimary.withOpacity(0.3)
                    : GameColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? GameColors.buttonPrimary
                    : GameColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? GameColors.textPrimary
                          : GameColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: GameColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: GameColors.buttonPrimary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

/// A hint row with icon and text
class _HintRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HintRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: GameColors.safeTileHighlight, size: 18),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(fontSize: 13, color: GameColors.textSecondary),
        ),
      ],
    );
  }
}
