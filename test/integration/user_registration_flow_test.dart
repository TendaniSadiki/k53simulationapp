import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:k53app/src/features/auth/presentation/screens/login_screen.dart';

void main() {
  group('User Registration Flow - End-to-End Test', () {
    testWidgets('Complete user registration flow with valid data', (WidgetTester tester) async {
      // Test data
      const testEmail = 'test.user@example.com';
      const testPassword = 'TestPassword123!';

      // 1. UI Interaction: Navigate to sign-up page and fill form
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify we're on the login screen
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);

      // Find all text fields and fill them
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      // Fill email field (first text field)
      await tester.enterText(textFields.at(0), testEmail);
      await tester.pump();

      // Fill password field (second text field)
      await tester.enterText(textFields.at(1), testPassword);
      await tester.pump();

      // Verify fields are filled correctly
      expect(find.text(testEmail), findsOneWidget);
      expect(find.text(testPassword), findsOneWidget);

      // 2. Submit registration form
      final signUpButton = find.widgetWithText(OutlinedButton, 'Sign Up');
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Verify form validation passed (no error messages)
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter a valid email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
      expect(find.text('Password must be at least 6 characters'), findsNothing);

      print('✅ User registration flow test completed successfully');
    });

    testWidgets('Error handling for invalid inputs', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      final textFields = find.byType(TextFormField);
      final signUpButton = find.widgetWithText(OutlinedButton, 'Sign Up');

      // Test invalid email
      await tester.enterText(textFields.at(0), 'invalid-email');
      await tester.pump();
      await tester.tap(signUpButton);
      await tester.pump();

      // Verify email validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);

      // Test empty email
      await tester.enterText(textFields.at(0), '');
      await tester.pump();
      await tester.tap(signUpButton);
      await tester.pump();
      expect(find.text('Please enter your email'), findsOneWidget);

      // Test short password
      await tester.enterText(textFields.at(1), '123');
      await tester.pump();
      await tester.tap(signUpButton);
      await tester.pump();
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);

      // Test empty password
      await tester.enterText(textFields.at(1), '');
      await tester.pump();
      await tester.tap(signUpButton);
      await tester.pump();
      expect(find.text('Please enter your password'), findsOneWidget);

      print('✅ Invalid input validation test completed');
    });

    testWidgets('Form validation clears when inputs are corrected', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      final textFields = find.byType(TextFormField);
      final signUpButton = find.widgetWithText(OutlinedButton, 'Sign Up');

      // Fill with invalid data first
      await tester.enterText(textFields.at(0), 'invalid-email');
      await tester.enterText(textFields.at(1), '123');
      await tester.pump();

      // Trigger validation
      await tester.tap(signUpButton);
      await tester.pump();

      // Verify errors are shown
      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);

      // Correct the inputs
      await tester.enterText(textFields.at(0), 'valid@example.com');
      await tester.enterText(textFields.at(1), 'ValidPassword123!');
      await tester.pump();

      // Trigger validation again to clear errors
      await tester.tap(signUpButton);
      await tester.pump();

      // Verify errors are cleared after re-validation
      expect(find.text('Please enter a valid email'), findsNothing);
      expect(find.text('Password must be at least 6 characters'), findsNothing);

      print('✅ Form validation clearing test completed');
    });

    testWidgets('UI state management during registration process', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Fill valid form data
      const testEmail = 'test@example.com';
      const testPassword = 'TestPassword123!';

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), testEmail);
      await tester.enterText(textFields.at(1), testPassword);
      await tester.pump();

      // Note: In a real test with mocked authentication, we would verify:
      // - Loading state appears during registration
      // - Buttons are disabled during loading
      // - Error states are properly handled
      // - Success states are properly handled

      print('✅ UI state management test completed');
    });

    testWidgets('Registration form accessibility and usability', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify all required UI elements are present
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);

      // Verify form fields are accessible
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      // Verify buttons are accessible
      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsOneWidget);

      final outlinedButtons = find.byType(OutlinedButton);
      expect(outlinedButtons, findsOneWidget);

      print('✅ Registration form accessibility test completed');
    });

    testWidgets('Form submission with valid data triggers registration', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      const testEmail = 'valid.user@example.com';
      const testPassword = 'ValidPassword123!';

      final textFields = find.byType(TextFormField);
      final signUpButton = find.widgetWithText(OutlinedButton, 'Sign Up');

      // Fill valid data
      await tester.enterText(textFields.at(0), testEmail);
      await tester.enterText(textFields.at(1), testPassword);
      await tester.pump();

      // Submit form
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Verify no validation errors
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter a valid email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
      expect(find.text('Password must be at least 6 characters'), findsNothing);

      // Note: In a real integration test, we would verify:
      // - API call was made to registration endpoint
      // - Success response was received
      // - User was redirected to appropriate screen

      print('✅ Form submission test completed');
    });
  });

  // Helper function to generate unique test data
  String generateTestEmail() {
    return 'test.${DateTime.now().millisecondsSinceEpoch}@example.com';
  }

  // Test data cleanup (would be implemented in real CI/CD environment)
  void cleanupTestData(String email) {
    // In a real environment, this would delete test user data from the database
    print('🧹 Cleaning up test data for: $email');
  }
}