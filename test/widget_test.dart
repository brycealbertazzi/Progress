import 'package:flutter_test/flutter_test.dart';
import 'package:progress/main.dart';

void main() {
  testWidgets('Home screen renders exercise list', (WidgetTester tester) async {
    await tester.pumpWidget(const ProgressApp());

    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('Deadlift'), findsOneWidget);
  });
}
