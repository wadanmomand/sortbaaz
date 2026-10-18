import '../game/sort_game.dart';

/// Finds a helpful move suggestion.
class HintFinder {
  /// Returns (from, to) for a good move, or null if none found.
  /// Priority:
  /// 1. Move that completes a full tube of one color.
  /// 2. Move onto a matching color (stacking).
  /// 3. Move to an empty tube (only if the arrow is "stuck").
  static (int, int)? findHint(SortGame game) {
    final moves = game.legalMoves();
    if (moves.isEmpty) return null;

    // 1. Completing move: destination becomes full with one color.
    for (final (f, t) in moves) {
      final dest = game.tubes[t];
      final moving = game.tubes[f].last;
      if (dest.length + 1 == game.tubeCapacity &&
          dest.every((a) => a == moving)) {
        return (f, t);
      }
    }

    // 2. Stacking: move onto matching color (not empty).
    for (final (f, t) in moves) {
      if (game.tubes[t].isNotEmpty) {
        // Prefer moves where source top matches and source isn't
        // already a clean stack we shouldn't break.
        if (!_isCleanStack(game, f)) return (f, t);
      }
    }

    // 3. Any stacking move.
    for (final (f, t) in moves) {
      if (game.tubes[t].isNotEmpty) return (f, t);
    }

    // 4. Move to empty tube (last resort).
    return moves.first;
  }

  /// A tube is a "clean stack" if all arrows are the same color —
  /// we shouldn't break it apart.
  static bool _isCleanStack(SortGame game, int tube) {
    final t = game.tubes[tube];
    if (t.isEmpty) return false;
    return t.every((a) => a == t.first);
  }
}
