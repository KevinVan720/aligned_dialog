import 'package:example/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs [body] while ignoring the errors of [NetworkImage]s: the example shows
/// images from the network, which is not available in widget tests.
Future<void> ignoringNetworkImageErrors(Future<void> Function() body) async {
  final FlutterExceptionHandler? onError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception is NetworkImageLoadException) {
      return;
    }
    onError?.call(details);
  };
  try {
    await body();
  } finally {
    FlutterError.onError = onError;
  }
}

void main() {
  testWidgets('opens and closes an aligned dialog', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await ignoringNetworkImageErrors(() async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('Flutter Demo Home Page'), findsOneWidget);
      expect(find.text('Tap to close'), findsNothing);

      final Finder button = find.text('Tap to show a local dialog').first;
      await tester.tap(button);
      await tester.pumpAndSettle();

      // The dialog opens right below the button, left edges aligned.
      final Finder close = find.text('Tap to close');
      expect(close, findsOneWidget);
      final Rect buttonRect = tester.getRect(
        find.ancestor(of: button, matching: find.byType(ElevatedButton)),
      );
      final Rect dialogRect = tester.getRect(
        find.ancestor(of: close, matching: find.byType(IntrinsicWidth)),
      );
      expect(dialogRect.top, buttonRect.bottom);
      expect(dialogRect.left, greaterThanOrEqualTo(buttonRect.left));

      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(find.text('Tap to close'), findsNothing);
    });
  });

  testWidgets('opens and closes a drawer', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await ignoringNetworkImageErrors(() async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text('Tap to show a right drawer'));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsOneWidget);
      expect(tester.getRect(find.byType(Drawer)).right, 1200);

      // Tapping the barrier closes the drawer.
      await tester.tapAt(const Offset(10, 800));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);
    });
  });
}
