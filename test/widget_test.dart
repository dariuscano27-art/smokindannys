import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smokindannys/main.dart';

void main() {
  testWidgets('Smokin Dannys app starts and shows title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SmokinDannysApp(),
      ),
    );

    // Verify that splash screen shows Smokin Dannys
    expect(find.text('Smokin Dannys'), findsOneWidget);
  });
}
