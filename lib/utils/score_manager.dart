import 'package:shared_preferences/shared_preferences.dart';

/// Manages local high score persistence using SharedPreferences.
class ScoreManager {
  static const String _highScoreKey = 'high_score';

  // Singleton instance
  static ScoreManager? _instance;
  static ScoreManager get instance => _instance ??= ScoreManager._();

  ScoreManager._();

  SharedPreferences? _prefs;

  /// Initialize the score manager (call once at app startup)
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Gets the current high score
  int getHighScore() {
    return _prefs?.getInt(_highScoreKey) ?? 0;
  }

  /// Updates the high score if the new score is higher
  /// Returns true if a new high score was set
  Future<bool> updateHighScore(int newScore) async {
    final currentHighScore = getHighScore();
    if (newScore > currentHighScore) {
      await _prefs?.setInt(_highScoreKey, newScore);
      return true;
    }
    return false;
  }

  /// Resets the high score to zero (for testing/debugging)
  Future<void> resetHighScore() async {
    await _prefs?.setInt(_highScoreKey, 0);
  }
}
