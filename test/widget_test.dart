import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zihinlab/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ZihinLab displays the first logic puzzle', (tester) async {
    await tester.pumpWidget(const ZihinLabApp());
    await tester.pumpAndSettle();

    expect(find.text('ZihinLab'), findsOneWidget);
    expect(find.text('Sayı dizisi'), findsOneWidget);
  });
}
