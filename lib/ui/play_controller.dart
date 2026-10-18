import 'package:flutter/foundation.dart';
import '../game/sort_game.dart';
import '../game/hint.dart';
import '../game/sound_service.dart';

/// State for one active level: game + selection + move history (undo).
class PlayController extends ChangeNotifier {
  final int level;
  late SortGame game;
  int? selectedTube;
  final List<(int, int)> _history = [];
  int moves = 0;

  /// Currently hinted move (from, to), cleared on next tap.
  (int, int)? hintMove;

  PlayController(this.level) {
    game = LevelGenerator.generate(level);
  }

  /// Tap a tube: select, deselect, or attempt move.
  void tapTube(int index) {
    hintMove = null; // clear hint on any tap
    if (selectedTube == null) {
      // Select if tube has arrows.
      if (game.tubes[index].isNotEmpty) {
        selectedTube = index;
        SoundService().tap();
        notifyListeners();
      }
    } else if (selectedTube == index) {
      selectedTube = null;
      SoundService().tap();
      notifyListeners();
    } else {
      final from = selectedTube!;
      if (game.canMove(from, index)) {
        game.move(from, index);
        _history.add((from, index));
        moves++;
        selectedTube = null;
        SoundService().move();
        notifyListeners();
      } else {
        // Invalid move: error sound.
        if (game.tubes[index].isEmpty ||
            game.tubes[from].isEmpty) {
          SoundService().error();
        }
        // Switch selection to the tapped tube if it has arrows.
        selectedTube = game.tubes[index].isNotEmpty ? index : null;
        notifyListeners();
      }
    }
  }

  /// Show a hint: highlights the suggested from/to tubes.
  /// Returns false if no hint available.
  bool showHint() {
    final hint = HintFinder.findHint(game);
    if (hint == null) return false;
    hintMove = hint;
    selectedTube = null;
    notifyListeners();
    return true;
  }

  bool get canUndo => _history.isNotEmpty;

  void undo() {
    if (_history.isEmpty) return;
    final (from, to) = _history.removeLast();
    // Reverse: move top of `to` back to `from`.
    game.tubes[from].add(game.tubes[to].removeLast());
    moves--;
    selectedTube = null;
    notifyListeners();
  }

  void restart() {
    game = LevelGenerator.generate(level);
    _history.clear();
    moves = 0;
    selectedTube = null;
    notifyListeners();
  }

  bool get isWon => game.isSolved;
}
