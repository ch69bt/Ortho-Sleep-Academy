import 'package:flutter_test/flutter_test.dart';
import 'package:ortho_luxmeter/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OrthoLuxmeterApp());
    expect(find.text('Ortho Luxmeter'), findsOneWidget);
  });
}
