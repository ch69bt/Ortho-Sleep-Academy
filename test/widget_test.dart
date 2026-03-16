import 'package:flutter_test/flutter_test.dart';
import 'package:ortho_sleep_academy/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OrthoSleepAcademyApp());
    expect(find.text('ORTHO SLEEP ACADEMY'), findsOneWidget);
  });
}
