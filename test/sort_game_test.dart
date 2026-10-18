import 'package:sort_baaz/game/sort_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('move and win', () {
    final g = SortGame(<List<ArrowColor>>[
      <ArrowColor>[ArrowColor.red, ArrowColor.blue],
      <ArrowColor>[ArrowColor.red, ArrowColor.red, ArrowColor.red],
      <ArrowColor>[ArrowColor.blue, ArrowColor.blue, ArrowColor.blue],
      <ArrowColor>[],
    ]);
    expect(g.move(0, 3), isTrue);
    expect(g.move(2, 3), isTrue);
    expect(g.move(2, 3), isTrue);
    expect(g.move(2, 3), isTrue);
    expect(g.move(0, 1), isTrue);
    expect(g.isSolved, isTrue);
  });

  test('canMove allows same color or empty', () {
    final g = SortGame(<List<ArrowColor>>[
      <ArrowColor>[ArrowColor.red, ArrowColor.blue],
      <ArrowColor>[ArrowColor.blue],
      <ArrowColor>[],
    ]);
    expect(g.canMove(0, 1), isTrue);
    expect(g.canMove(0, 2), isTrue);
    expect(g.canMove(2, 0), isFalse);
    expect(g.canMove(0, 0), isFalse);
  });

  test('canMove rejects full tube', () {
    final g = SortGame(<List<ArrowColor>>[
      <ArrowColor>[ArrowColor.red],
      <ArrowColor>[ArrowColor.red, ArrowColor.red, ArrowColor.red, ArrowColor.red],
    ]);
    expect(g.canMove(0, 1), isFalse);
  });

  test('mixed tube not solved', () {
    final g = SortGame(<List<ArrowColor>>[
      <ArrowColor>[ArrowColor.red, ArrowColor.blue, ArrowColor.red, ArrowColor.red],
    ]);
    expect(g.isSolved, isFalse);
  });

  test('difficulty bands', () {
    expect(LevelGenerator.difficultyOf(1), Difficulty.easy);
    expect(LevelGenerator.difficultyOf(1000), Difficulty.easy);
    expect(LevelGenerator.difficultyOf(1001), Difficulty.medium);
    expect(LevelGenerator.difficultyOf(7000), Difficulty.hard);
    expect(LevelGenerator.difficultyOf(7001), Difficulty.expert);
    expect(LevelGenerator.difficultyOf(10000), Difficulty.expert);
  });

  test('generator deterministic', () {
    final a = LevelGenerator.generate(42);
    final b = LevelGenerator.generate(42);
    expect(a.tubes.toString(), b.tubes.toString());
  });

  test('generator valid puzzles', () {
    for (final lvl in [1, 500, 2500, 8000, 10000]) {
      final g = LevelGenerator.generate(lvl);
      expect(g.isSolved, isFalse);
      final total = g.tubes.expand((t) => t).length;
      final (colors, _) = LevelGenerator.configOf(lvl);
      expect(total, colors * 4);
      expect(g.legalMoves().isNotEmpty, isTrue);
    }
  });
}
