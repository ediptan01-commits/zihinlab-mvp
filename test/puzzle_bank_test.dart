import 'package:flutter_test/flutter_test.dart';
import 'package:zihinlab/data/puzzle_bank.dart';
import 'package:zihinlab/models/puzzle.dart';
import 'package:zihinlab/services/progress_store.dart';

void main() {
  test('starter bank has 25 validated puzzles across five modes', () {
    expect(validatePuzzleBank(puzzleBank), isTrue);
    expect(puzzleBank, hasLength(25));
    expect(puzzleBank.map((puzzle) => puzzle.id).toSet(), hasLength(25));
    for (final mode in [
      PuzzleMode.logic,
      PuzzleMode.moves,
      PuzzleMode.visual,
      PuzzleMode.mystery,
      PuzzleMode.memory,
    ]) {
      expect(puzzleBank.where((puzzle) => puzzle.mode == mode), hasLength(5));
    }
  });

  test('every sliding board is a solvable permutation of the target tiles', () {
    for (final puzzle in puzzleBank.where((item) => item.mode == PuzzleMode.moves)) {
      expect(puzzle.slideStart.toSet(), {0, 1, 2, 3, 4, 5, 6, 7, 8});
      final numbers = puzzle.slideStart.where((tile) => tile != 0).toList();
      var inversions = 0;
      for (var i = 0; i < numbers.length; i++) {
        for (var j = i + 1; j < numbers.length; j++) {
          if (numbers[i] > numbers[j]) inversions++;
        }
      }
      expect(inversions.isEven, isTrue, reason: puzzle.id + ' can reach the goal');
    }
  });

  test('answer matching handles surrounding spaces and Turkish characters', () {
    expect(puzzleBank.first.accepts(' 42 '), isTrue);
    expect(puzzleBank[1].accepts('yalnızca kırmızı'), isTrue);
  });

  test('legacy progress loads and new review and daily data round-trips', () {
    final legacy = PlayerProgress.fromJson({'solved': {'older': 2}, 'score': 80});
    expect(legacy.solvedCount, 1);
    expect(legacy.score, 80);

    final today = DateTime(2026, 10, 23);
    final updated = legacy.solve('daily-' + dateKey(today), 3, 150,
        mode: PuzzleMode.daily, date: today, daily: true);
    final restored = PlayerProgress.fromJson(updated.toJson());
    expect(restored.dailyStreak(today), 1);
    expect(restored.reviewDue['daily-' + dateKey(today)],
        dateKey(DateTime(2026, 10, 30)));
    expect(restored.correctFor(PuzzleMode.daily), 1);
  });
}
