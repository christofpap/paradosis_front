import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paradosis_flutter/main.dart';

void main() {
  testWidgets('MapPage UI loads basic elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: map_page()));

    // AppBar πρέπει να υπάρχει
    expect(find.byType(AppBar), findsOneWidget);

    // Αν έχεις στατικό κείμενο
    expect(find.text('Χάρτης'), findsOneWidget);
  });
}
