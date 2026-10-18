import 'dart:math';

/// Arrow colors available in the game.
enum ArrowColor { red, blue, green, yellow, purple, orange }

/// Difficulty bands for the 10,000 levels.
enum Difficulty { easy, medium, hard, expert }

/// Core rules engine for SortBaaz sort puzzle.
class SortGame {
  /// Tubes, each a stack of arrows (index 0 = bottom).
  final List<List<ArrowColor>> tubes;

  /// Max arrows per tube.
  final int tubeCapacity;

  SortGame(this.tubes, {this.tubeCapacity = 4});

  int get tubeCount => tubes.length;

  /// Top arrow of a tube, or null if empty.
  ArrowColor? topOf(int tube) =>
      tubes[tube].isEmpty ? null : tubes[tube].last;

  /// Whether an arrow can move from [from] to [to].
  bool canMove(int from, int to) {
    if (from == to) return false;
    if (tubes[from].isEmpty) return false;
    if (tubes[to].length >= tubeCapacity) return false;
    final moving = tubes[from].last;
    if (tubes[to].isEmpty) return true;
    return tubes[to].last == moving;
  }

  /// All valid (from, to) moves right now.
  List<(int, int)> legalMoves() {
    final moves = <(int, int)>[];
    for (var f = 0; f < tubeCount; f++) {
      for (var t = 0; t < tubeCount; t++) {
        if (canMove(f, t)) moves.add((f, t));
      }
    }
    return moves;
  }

  /// Moves the top arrow from [from] to [to]. Returns false if illegal.
  bool move(int from, int to) {
    if (!canMove(from, to)) return false;
    tubes[to].add(tubes[from].removeLast());
    return true;
  }

  /// Win: every tube is empty or full with a single color.
  bool get isSolved {
    for (final tube in tubes) {
      if (tube.isEmpty) continue;
      if (tube.length != tubeCapacity) return false;
      final c = tube.first;
      if (!tube.every((a) => a == c)) return false;
    }
    return true;
  }

  /// Deep copy.
  SortGame copy() => SortGame(
        [for (final t in tubes) List<ArrowColor>.of(t)],
        tubeCapacity: tubeCapacity,
      );
}

/// Generates solvable levels. Level number (1-10000) is the seed,
/// so the same level always deals the same puzzle.
class LevelGenerator {
  static const int maxLevel = 10000;

  static Difficulty difficultyOf(int level) {
    if (level <= 1000) return Difficulty.easy;
    if (level <= 4000) return Difficulty.medium;
    if (level <= 7000) return Difficulty.hard;
    return Difficulty.expert;
  }

  /// (colors, totalTubes) for a level.
  static (int, int) configOf(int level) {
    final d = difficultyOf(level);
    final colors = switch (d) {
      Difficulty.easy => 3,
      Difficulty.medium => 4,
      Difficulty.hard => 5,
      Difficulty.expert => 6,
    };
    // Tubes = colors + 2 empty (easy) down to colors + 1 (expert).
    final extra = d == Difficulty.expert ? 1 : 2;
    return (colors, colors + extra);
  }

  /// Generates a level by dealing a solved state then shuffling with
  /// random valid moves — guarantees solvability (reverse the shuffle).
  static SortGame generate(int level, {int tubeCapacity = 4}) {
    assert(level >= 1 && level <= maxLevel);
    return _generateWithSeed(level, 0, tubeCapacity: tubeCapacity);
  }

  static SortGame _generateWithSeed(int level, int attempt,
      {required int tubeCapacity}) {
    final rng = Random(level * 7919 + attempt * 104729); // deterministic seed
    final (colorCount, tubeCount) = configOf(level);
    final colors = ArrowColor.values.take(colorCount).toList();

    // Start solved: one full tube per color.
    final tubes = <List<ArrowColor>>[
      for (final c in colors) List<ArrowColor>.of(List.filled(tubeCapacity, c)),
      for (var i = 0; i < tubeCount - colorCount; i++) <ArrowColor>[],
    ];
    final game = SortGame(tubes, tubeCapacity: tubeCapacity);

    // Shuffle with random legal moves (more shuffles = harder).
    final shuffles = 30 + rng.nextInt(40) + level ~/ 200;
    var done = 0;
    var guard = 0;
    while (done < shuffles && guard < shuffles * 20) {
      guard++;
      final moves = game.legalMoves();
      if (moves.isEmpty) break;
      final (f, t) = moves[rng.nextInt(moves.length)];
      game.move(f, t);
      done++;
    }

    // Reject trivially-solved deals: retry with a different seed,
    // keeping the same level number (and difficulty).
    if (game.isSolved) {
      return _generateWithSeed(level, attempt + 1, tubeCapacity: tubeCapacity);
    }
    return game;
  }
}
