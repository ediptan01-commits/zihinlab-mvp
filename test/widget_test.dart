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
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ZihinLabApp());
    await tester.pumpAndSettle();
  }

  Future<void> chooseAnswer(WidgetTester tester, String answer) async {
    final optionCard = find
        .ancestor(of: find.text(answer), matching: find.byType(InkWell))
        .first;
    await tester.tap(optionCard);
    await tester.pump();
    final checkButton = find.widgetWithText(FilledButton, 'Kontrol et');
    expect(tester.widget<FilledButton>(checkButton).onPressed, isNotNull);
    await tester.tap(checkButton);
    await tester.pumpAndSettle();
  }

  testWidgets('first puzzle has selectable answers and a Turkish mode picker', (
    tester,
  ) async {
    await openGame(tester);
    expect(find.text('ZihinLab'), findsOneWidget);
    expect(find.text('Sayı merdiveni'), findsOneWidget);
    expect(find.text('BİR CEVAP SEÇ'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Mantık'), findsOneWidget);
    expect(find.text('Hamle'), findsOneWidget);
    expect(find.text('Görsel'), findsOneWidget);
    expect(find.text('Gizem'), findsOneWidget);
    expect(find.text('Hafıza'), findsOneWidget);
    expect(find.text('Günlük'), findsOneWidget);
  });

  testWidgets('wrong choice reveals a hint without giving the answer away', (
    tester,
  ) async {
    await openGame(tester);
    final puzzle = puzzleBank.first;
    final wrongAnswer = puzzle.options.firstWhere(
      (option) => !puzzle.accepts(option),
    );
    await chooseAnswer(tester, wrongAnswer);
    expect(find.textContaining('Henüz değil'), findsOneWidget);
    expect(find.textContaining('Küçük ipucu'), findsOneWidget);
    expect(find.text(puzzle.explanation), findsNothing);
  });

  testWidgets('correct choice awards stars and explains the skill', (
    tester,
  ) async {
    await openGame(tester);
    final puzzle = puzzleBank.first;
    await chooseAnswer(tester, puzzle.options.firstWhere(puzzle.accepts));
    expect(find.textContaining('Harika, doğru cevap!'), findsOneWidget);
    expect(
      find.text('Bu turda çalıştırdığın beceri: ' + puzzle.skill),
      findsOneWidget,
    );
    expect(find.text('Sonraki bulmaca'), findsOneWidget);
  });

  testWidgets('sliding mode reaches the goal by moving adjacent tiles', (
    tester,
  ) async {
    await openGame(tester);
    await tester.tap(find.text('Hamle'));
    await tester.pumpAndSettle();
    expect(find.text('İki hamlede hedef'), findsOneWidget);
    await tester.ensureVisible(find.text('5'));
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('6'));
    await tester.tap(find.text('6'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Harika, doğru cevap!'), findsOneWidget);
  });

  testWidgets('memory mode hides the sequence before answer selection', (
    tester,
  ) async {
    await openGame(tester);
    await tester.tap(find.text('Hafıza'));
    await tester.pumpAndSettle();
    expect(find.text('SIRAYI İNCELE'), findsOneWidget);
    await tester.tap(find.text('Hazırım, gizle'));
    await tester.pumpAndSettle();
    expect(find.text('SIRA GİZLENDİ'), findsOneWidget);
    expect(find.text('BİR CEVAP SEÇ'), findsOneWidget);
  });

  testWidgets('difference cards mark all three changes before checking', (
    tester,
  ) async {
    await openGame(tester);
    await tester.tap(find.text('Görsel'));
    await tester.pumpAndSettle();

    final puzzle = puzzleBank.firstWhere((item) => item.isDifferencePuzzle);
    expect(find.text(puzzle.title), findsOneWidget);
    expect(find.text('KART A'), findsOneWidget);
    expect(find.text('KART B'), findsOneWidget);

    for (final position in puzzle.differencePositions) {
      final tile = find.byKey(ValueKey('difference-a-$position'));
      await tester.ensureVisible(tile);
      await tester.tap(tile);
      await tester.pumpAndSettle();
    }

    expect(find.text('3 / 3 fark bulundu'), findsOneWidget);
    final checkButton = find.widgetWithText(
      FilledButton,
      'Farkları kontrol et',
    );
    expect(tester.widget<FilledButton>(checkButton).onPressed, isNotNull);
    await tester.ensureVisible(checkButton);
    await tester.tap(checkButton);
    await tester.pumpAndSettle();
    expect(find.textContaining('Harika, doğru cevap!'), findsOneWidget);
    expect(find.text('Sonraki bulmaca'), findsOneWidget);
  });
}
