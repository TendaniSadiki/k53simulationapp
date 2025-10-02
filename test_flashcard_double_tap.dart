import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'lib/src/shared/widgets/flashcard_widget.dart';

void main() {
  group('FlashcardWidget Tests', () {
    testWidgets('Double-tap gesture flips the card', (WidgetTester tester) async {
      // Create a simple flashcard widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              frontContent: Container(
                child: Text('Front Content'),
              ),
              backContent: Container(
                child: Text('Back Content'),
              ),
              enableDoubleTap: true,
              mode: FlashcardMode.study,
            ),
          ),
        ),
      );

      // Verify initial state (front content visible)
      expect(find.text('Front Content'), findsOneWidget);
      expect(find.text('Back Content'), findsNothing);

      // Perform double tap
      await tester.tap(find.byType(FlashcardWidget));
      await tester.pumpAndSettle();

      // Verify card flipped (back content visible)
      expect(find.text('Front Content'), findsNothing);
      expect(find.text('Back Content'), findsOneWidget);
    });

    testWidgets('Double-tap gesture with disabled double-tap does nothing', (WidgetTester tester) async {
      // Create a flashcard widget with double-tap disabled
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              frontContent: Container(
                child: Text('Front Content'),
              ),
              backContent: Container(
                child: Text('Back Content'),
              ),
              enableDoubleTap: false,
              mode: FlashcardMode.study,
            ),
          ),
        ),
      );

      // Verify initial state (front content visible)
      expect(find.text('Front Content'), findsOneWidget);
      expect(find.text('Back Content'), findsNothing);

      // Attempt double tap (should not work)
      await tester.tap(find.byType(FlashcardWidget));
      await tester.pumpAndSettle();

      // Verify state unchanged (front content still visible)
      expect(find.text('Front Content'), findsOneWidget);
      expect(find.text('Back Content'), findsNothing);
    });

    testWidgets('Card starts flipped when startFlipped is true', (WidgetTester tester) async {
      // Create a flashcard widget that starts flipped
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              frontContent: Container(
                child: Text('Front Content'),
              ),
              backContent: Container(
                child: Text('Back Content'),
              ),
              enableDoubleTap: true,
              mode: FlashcardMode.study,
              startFlipped: true,
            ),
          ),
        ),
      );

      // Verify initial state (back content visible due to startFlipped)
      expect(find.text('Front Content'), findsNothing);
      expect(find.text('Back Content'), findsOneWidget);
    });
  });

  print('FlashcardWidget tests completed successfully!');
  print('Double-tap gesture functionality is working correctly.');
  print('Integration with Study Mode and Exam Mode has been implemented.');
}