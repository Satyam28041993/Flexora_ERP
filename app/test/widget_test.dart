import 'package:flutter_test/flutter_test.dart';

import 'package:flexora/main.dart';

void main() {
  testWidgets('App shows a Firebase-not-configured message when unconfigured',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const FlexoraApp(firebaseInitError: 'not configured in test environment'),
    );

    expect(find.text('Firebase is not configured yet'), findsOneWidget);
  });
}
