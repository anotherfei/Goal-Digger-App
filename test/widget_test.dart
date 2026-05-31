import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_digger_flutter/features/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('auth gateway switches between login and signup', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(
          isLoading: false,
          errorMessage: null,
          onClearError: () {},
          onPasswordReset: (_) async => true,
          onEmailAuth: (email, password, displayName, isSignUp) async {},
          onGoogle: () {},
          onGuest: () {},
        ),
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Create your account'), findsNothing);

    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
  });

  testWidgets('forgot password sends neutral reset feedback', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    String? resetEmail;

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(
          isLoading: false,
          errorMessage: null,
          onClearError: () {},
          onPasswordReset: (email) async {
            resetEmail = email;
            return true;
          },
          onEmailAuth: (email, password, displayName, isSignUp) async {},
          onGoogle: () {},
          onGuest: () {},
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'ada@example.com');
    await tester.tap(find.text('Forgot password?'));
    await tester.pump();

    expect(resetEmail, 'ada@example.com');
    expect(
      find.text(
          'If this email uses password login, reset instructions were sent.'),
      findsOneWidget,
    );
  });
}
