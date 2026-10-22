import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zihinlab/data/puzzle_bank.dart';
import 'package:zihinlab/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> openGame(WidgetTester tester) async {
    await tester.pumpWidget(const ZihinLabApp());
    await tester.pumpAndSettle();
  }

  testWidgets('puzzles show selectable answers instead of a text field', (tester) async {
    await openGame(tester);

    expect(find.text('ZihinLab'), findsOneWidget);
    expect(find.text('Sayı dizisi'), findsOneWidget);
    expect(find.text('BİR CEVAP SEÇ'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text(puzzleBank.first.options.first), findsOneWidget);
  });

  testWidgets('wrong choice shows feedback and the explanation', (tester) async {
    await openGame(tester);
    final puzzle = puzzleBank.first;
    final wrongAnswer = puzzle.options.firstWhere((option) => !puzzle.accepts(option));

    await tester.tap(find.text(wrongAnswer));
    await tester.tap(find.text('Cevabı kontrol et'));
    await tester.pumpAndSettle();

    expect(find.text('Henüz değil, tekrar düşün!'), findsOneWidget);
    expect(find.text(puzzle.explanation), findsOneWidget);
  });

  testWidgets('correct choice awards points and unlocks the next puzzle', (tester) async {
    await openGame(tester);
    final puzzle = puzzleBank.first;
    final correctAnswer = puzzle.options.firstWhere(puzzle.accepts);

    await tester.tap(find.text(correctAnswer));
    await tester.tap(find.text('Cevabı kontrol et'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Harika, doğru cevap!'), findsOneWidget);
    expect(find.textContaining('100 puan'), findsOneWidget);
    expect(find.text('Sonraki seviye'), findsOneWidget);
  });
}
