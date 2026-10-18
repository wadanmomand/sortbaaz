import 'package:sort_baaz/game/hint.dart';
import 'package:sort_baaz/game/sort_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hint suggests completing move first', () {
    // Tube 1 has 3 blues, tube 0 has blue on top -> completing move.
    final g = SortGame(<List<ArrowColor>>[
      <ArrowColor>[ArrowColor.red, ArrowColor.blue],
      <ArrowColor>[ArrowColor.blue, ArrowColor.blue, ArrowColor.blue],
      <ArrowColor>[],
    ]);
    final hint = HintFinder.findHint(g);
    expect(hint, isNotNull);
    // Should suggest moving blue from 0 to 1 (completes the tube).
    expect(hint!.$1, 0);
    expect(hint.$2, 1);
  });

  test('hint avoids breaking clean stacks', () {
    // Tube 0 is clean (all red). Tube 1 has mixed.
    // Hint should not suggest taking from the clean tube 0.
    final g = SortGame(<List<ArrowColor>>[
      <ArrowColor>[ArrowColor.red, ArrowColor.red],
      <ArrowColor>[ArrowColor.blue, ArrowColor.red],
      <ArrowColor>[],
    ]);
    final hint = HintFinder.findHint(g);
    expect(hint, isNotNull);
    // Should not break the clean red stack in tube 0.
    expect(hint!.$1, isNot(0));
  });

  test('hint returns null when no moves', () {
    final g = SortGame(<List<ArrowColor>>[
      <ArrowColor>[
        ArrowColor.red,
        ArrowColor.red,
        ArrowColor.red,
        ArrowColor.red
      ],
      <ArrowColor>[
        ArrowColor.blue,
        ArrowColor.blue,
        ArrowColor.blue,
        ArrowColor.blue
      ],
    ]);
    expect(HintFinder.findHint(g), isNull);
  });
}
