import 'package:deskovky/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DeskovkyApp starts on the Games tab', (tester) async {
    await tester.pumpWidget(const DeskovkyApp());
    await tester.pumpAndSettle();
    expect(find.byType(DeskovkyApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
