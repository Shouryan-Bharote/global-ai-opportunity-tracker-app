import 'package:ai_nexus/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots and renders without crashing', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    // Allow initial frame + any immediate async work to settle.
    await tester.pump(const Duration(milliseconds: 300));

    // The app should render at least one widget without crashing.
    // Depending on Firebase auth state in test environment it will either:
    // (a) Show SplashScreen with 'AI' logo text, or
    // (b) Redirect immediately to /auth (if authStateChanges fires first).
    // Either way the app booted successfully — no exceptions thrown.
    expect(tester.takeException(), isNull);

    // Advance timer past the 2-second splash navigation delay.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });
}
