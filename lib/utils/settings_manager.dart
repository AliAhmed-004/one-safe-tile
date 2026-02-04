import 'package:shared_preferences/shared_preferences.dart';

/// Control mode options
enum ControlMode {
  twoHand, // Joystick + Jump button
  oneHand, // Swipe to move + Tap to jump
}

/// Manages game settings persistence using SharedPreferences.
class SettingsManager {
  static const String _controlModeKey = 'control_mode';

  // Singleton instance
  static SettingsManager? _instance;
  static SettingsManager get instance => _instance ??= SettingsManager._();

  SettingsManager._();

  SharedPreferences? _prefs;

  /// Initialize the settings manager (call once at app startup)
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Gets the current control mode
  ControlMode getControlMode() {
    final modeIndex = _prefs?.getInt(_controlModeKey) ?? 0;
    return ControlMode.values[modeIndex.clamp(
      0,
      ControlMode.values.length - 1,
    )];
  }

  /// Sets the control mode
  Future<void> setControlMode(ControlMode mode) async {
    await _prefs?.setInt(_controlModeKey, mode.index);
  }

  /// Checks if using one-hand controls
  bool get isOneHandMode => getControlMode() == ControlMode.oneHand;

  /// Checks if using two-hand controls
  bool get isTwoHandMode => getControlMode() == ControlMode.twoHand;
}
