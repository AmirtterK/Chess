import 'package:flutter_test/flutter_test.dart';

import 'package:chess_ritter/main.dart';

void main() {
  testWidgets('shows the chess start screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Chess Ritter'), findsOneWidget);
    expect(find.text('New Game'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
