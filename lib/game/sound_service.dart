import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central sound manager for SortBaaz.
/// All sounds are generated locally (offline, no downloads).
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;
  static const _soundKey = 'sound_enabled';

  bool get enabled => _enabled;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_soundKey) ?? true;
    // Pre-load for low latency.
    await _player.setSource(AssetSource('sounds/tap.wav'));
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, value);
  }

  Future<void> _play(String file) async {
    if (!_enabled) return;
    try {
      await _player.play(AssetSource('sounds/$file'));
    } catch (_) {
      // Silently ignore audio errors (e.g., no audio device).
    }
  }

  Future<void> tap() => _play('tap.wav');
  Future<void> move() => _play('move.wav');
  Future<void> win() => _play('win.wav');
  Future<void> error() => _play('error.wav');
  Future<void> coin() => _play('coin.wav');
  Future<void> button() => _play('button.wav');
}
