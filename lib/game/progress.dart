import 'package:shared_preferences/shared_preferences.dart';

/// Persistent player progress: coins, completed levels, stats.
class Progress {
  static const _coinsKey = 'coins';
  static const _completedKey = 'completed_levels';
  static const _totalMovesKey = 'total_moves';
  static const _hintsUsedKey = 'hints_used';
  static const _dailyKey = 'daily_done';

  final SharedPreferences _prefs;

  Progress(this._prefs);

  static Future<Progress> load() async {
    final prefs = await SharedPreferences.getInstance();
    return Progress(prefs);
  }

  int get coins => _prefs.getInt(_coinsKey) ?? 100; // start with 100
  Future<void> addCoins(int n) =>
      _prefs.setInt(_coinsKey, coins + n);
  Future<bool> spendCoins(int n) async {
    if (coins < n) return false;
    await _prefs.setInt(_coinsKey, coins - n);
    return true;
  }

  /// Highest level completed.
  int get completedUpTo => _prefs.getInt(_completedKey) ?? 0;
  Future<void> completeLevel(int level) async {
    if (level > completedUpTo) {
      await _prefs.setInt(_completedKey, level);
    }
    await addCoins(10 + level ~/ 100); // reward scales with level
  }

  int get totalMoves => _prefs.getInt(_totalMovesKey) ?? 0;
  Future<void> addMoves(int n) =>
      _prefs.setInt(_totalMovesKey, totalMoves + n);

  int get hintsUsed => _prefs.getInt(_hintsUsedKey) ?? 0;
  Future<void> addHintUsed() =>
      _prefs.setInt(_hintsUsedKey, hintsUsed + 1);

  /// Date string (yyyy-MM-dd) of last completed daily challenge.
  String? get dailyDone => _prefs.getString(_dailyKey);
  Future<void> markDailyDone(String date) =>
      _prefs.setString(_dailyKey, date);
}
