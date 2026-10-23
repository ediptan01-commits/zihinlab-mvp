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
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ZihinLabApp());
    await tester.pumpAndSettle();
  }

  Future<void> chooseAnswer(WidgetTester tester, String answer) async {
    final optionCard = find.ancestor(
      of: find.text(answer),
      matching: find.byType(InkWell),
    ).first;
    await tester.tap(optionCard);
    await tester.pump();

    final checkButton = find.widgetWithText(FilledButton, 'Cevabı kontrol et');
    expect(tester.widget<FilledButton>(checkButton).onPressed, isNotNull);
    await tester.tap(checkButton);
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

    await chooseAnswer(tester, wrongAnswer);

    expect(find.text('Henüz değil, tekrar düşün!'), findsOneWidget);
    expect(find.text(puzzle.explanation), findsOneWidget);
  });

  testWidgets('correct choice awards points and unlocks the next puzzle', (tester) async {
    await openGame(tester);
    final puzzle = puzzleBank.first;
    final correctAnswer = puzzle.options.firstWhere(puzzle.accepts);

    await chooseAnswer(tester, correctAnswer);

    expect(find.textContaining('Harika, doğru cevap!'), findsOneWidget);
    expect(find.text('100 puan'), findsOneWidget);
    expect(find.text('Sonraki seviye'), findsOneWidget);
  });
}
