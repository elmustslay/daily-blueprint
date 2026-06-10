import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';

void main() {
  testWidgets('Dashboard smoke test — all feature cards render', (WidgetTester tester) async {
    // Use a tall viewport so all grid cards are visible without scrolling
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(child: MyApp()),
    );
    await tester.pumpAndSettle();

    // App title in AppBar
    expect(find.text('Welcome back, El!'), findsOneWidget);

    // All 5 dashboard cards
    expect(find.text('Daily Plan'), findsOneWidget);
    expect(find.text('Gym Plan'), findsOneWidget);
    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Shopping List'), findsOneWidget);
    expect(find.text('Book Plan'), findsOneWidget);
  });
}
