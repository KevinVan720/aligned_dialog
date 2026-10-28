import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const Size kScreenSize = Size(800, 600);
const Size kTargetSize = Size(40, 20);
const Size kDialogSize = Size(100, 50);
const Key kTargetKey = Key('target');
const Key kDialogKey = Key('dialog');

/// Every anchor that the tests iterate over: the nine named [Alignment]s plus
/// a couple of arbitrary ones.
const List<Alignment> kAnchors = <Alignment>[
  Alignment.topLeft,
  Alignment.topCenter,
  Alignment.topRight,
  Alignment.centerLeft,
  Alignment.center,
  Alignment.centerRight,
  Alignment.bottomLeft,
  Alignment.bottomCenter,
  Alignment.bottomRight,
  Alignment(0.5, -0.25),
  Alignment(-2, 1.5),
];

/// Configures a deterministic 800x600 logical-pixel test view.
void setUpView(
  WidgetTester tester, {
  Size size = kScreenSize,
  FakeViewPadding padding = FakeViewPadding.zero,
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.view.padding = padding;
  tester.view.viewPadding = padding;
  addTearDown(tester.view.reset);
}

/// Pumps an app with a single target box whose top-left corner is at
/// [targetTopLeft] (in global coordinates).
Future<void> pumpTarget(
  WidgetTester tester, {
  Offset targetTopLeft = const Offset(380, 290),
  Size targetSize = kTargetSize,
  TextDirection textDirection = TextDirection.ltr,
}) {
  return tester.pumpWidget(
    MaterialApp(
      builder: (BuildContext context, Widget? child) =>
          Directionality(textDirection: textDirection, child: child!),
      home: Stack(
        children: <Widget>[
          Positioned(
            left: targetTopLeft.dx,
            top: targetTopLeft.dy,
            width: targetSize.width,
            height: targetSize.height,
            child: const SizedBox(key: kTargetKey),
          ),
        ],
      ),
    ),
  );
}

WidgetBuilder dialogBuilder({Size size = kDialogSize}) {
  return (BuildContext context) => SizedBox(
        key: kDialogKey,
        width: size.width,
        height: size.height,
        // Something that is hit testable, like real dialog content.
        child: const ColoredBox(color: Color(0xFFFFC107)),
      );
}

/// Keeps track of the future returned by a show* function.
class DialogResult<T> {
  DialogResult(Future<T?> future) {
    future.then((T? value) {
      this.value = value;
      completed = true;
    });
  }

  T? value;
  bool completed = false;
}

/// Opens a dialog from the target's context and waits for it to settle.
Future<DialogResult<T>> open<T>(
  WidgetTester tester,
  Future<T?> Function(BuildContext targetContext) show,
) async {
  final BuildContext targetContext = tester.element(find.byKey(kTargetKey));
  final DialogResult<T> result = DialogResult<T>(show(targetContext));
  await tester.pumpAndSettle();
  return result;
}

Future<void> closeDialog(WidgetTester tester, [Object? result]) async {
  Navigator.of(tester.element(find.byKey(kDialogKey))).pop(result);
  await tester.pumpAndSettle();
  expect(find.byKey(kDialogKey), findsNothing);
}

Rect dialogRect(WidgetTester tester) => tester.getRect(find.byKey(kDialogKey));

/// The rect at which a dialog of [kDialogSize] ends up when its
/// [followerAnchor] point is placed on the [targetAnchor] point of
/// [targetRect], shifted by [offset].
Rect expectedRect(
  Rect targetRect,
  Alignment targetAnchor,
  Alignment followerAnchor, {
  Offset offset = Offset.zero,
}) {
  final Offset topLeft = targetRect.topLeft +
      targetAnchor.alongSize(targetRect.size) -
      followerAnchor.alongSize(kDialogSize) +
      offset;
  return topLeft & kDialogSize;
}

void main() {
  group('showAlignedDialog local positioning', () {
    testWidgets('centers the dialog on the target by default', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);

      await open<void>(
        tester,
        (BuildContext context) =>
            showAlignedDialog(context: context, builder: dialogBuilder()),
      );

      // Target center is (400, 300); a 100x50 dialog centered on it.
      expect(dialogRect(tester), const Rect.fromLTWH(350, 275, 100, 50));
    });

    testWidgets('places the follower anchor on the target anchor', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.topLeft,
          targetAnchor: Alignment.bottomLeft,
        ),
      );

      // Dropdown-like: directly below the target, left edges aligned.
      expect(dialogRect(tester), const Rect.fromLTWH(380, 310, 100, 50));
      await closeDialog(tester);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.bottomRight,
          targetAnchor: Alignment.topRight,
        ),
      );

      // Directly above the target, right edges aligned.
      expect(dialogRect(tester), const Rect.fromLTWH(320, 240, 100, 50));
      await closeDialog(tester);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.centerLeft,
          targetAnchor: Alignment.centerRight,
        ),
      );

      // To the right of the target, vertically centered.
      expect(dialogRect(tester), const Rect.fromLTWH(420, 275, 100, 50));
    });

    testWidgets('works for every combination of anchors', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      const Rect targetRect = Rect.fromLTWH(380, 290, 40, 20);
      await pumpTarget(tester, targetTopLeft: targetRect.topLeft);

      for (final Alignment followerAnchor in kAnchors) {
        for (final Alignment targetAnchor in kAnchors) {
          for (final Offset offset in <Offset>[
            Offset.zero,
            const Offset(3, -7),
          ]) {
            await open<void>(
              tester,
              (BuildContext context) => showAlignedDialog(
                context: context,
                builder: dialogBuilder(),
                followerAnchor: followerAnchor,
                targetAnchor: targetAnchor,
                offset: offset,
              ),
            );
            expect(
              dialogRect(tester),
              expectedRect(
                targetRect,
                targetAnchor,
                followerAnchor,
                offset: offset,
              ),
              reason: 'follower: $followerAnchor, target: $targetAnchor, '
                  'offset: $offset',
            );
            await closeDialog(tester);
          }
        }
      }
    });

    testWidgets('adds the offset after aligning', (WidgetTester tester) async {
      setUpView(tester);
      await pumpTarget(tester);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.topLeft,
          targetAnchor: Alignment.bottomLeft,
          offset: const Offset(12, -8),
        ),
      );

      expect(dialogRect(tester), const Rect.fromLTWH(392, 302, 100, 50));
    });

    testWidgets('uses the size the dialog chooses', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(size: const Size(300, 120)),
          followerAnchor: Alignment.bottomCenter,
          targetAnchor: Alignment.topCenter,
        ),
      );

      expect(dialogRect(tester), const Rect.fromLTWH(250, 170, 300, 120));
    });

    testWidgets('allows the dialog to go off screen without avoidOverflow', (
      WidgetTester tester,
    ) async {
      setUpView(tester);

      // Top-left corner.
      await pumpTarget(tester, targetTopLeft: Offset.zero);
      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.bottomRight,
          targetAnchor: Alignment.topLeft,
        ),
      );
      expect(dialogRect(tester), const Rect.fromLTWH(-100, -50, 100, 50));
      await closeDialog(tester);

      // Bottom-right corner.
      await pumpTarget(tester, targetTopLeft: const Offset(760, 580));
      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.topLeft,
          targetAnchor: Alignment.bottomRight,
        ),
      );
      expect(dialogRect(tester), const Rect.fromLTWH(800, 600, 100, 50));
    });

    testWidgets('avoidOverflow keeps the dialog on screen near every edge', (
      WidgetTester tester,
    ) async {
      setUpView(tester);

      final Map<Offset, Rect> cases = <Offset, Rect>{
        // Target top-left corner -> dialog would be at (-100, -50).
        Offset.zero: const Rect.fromLTWH(0, 0, 100, 50),
        // Target top-right corner -> dialog would be at (800, -50).
        const Offset(760, 0): const Rect.fromLTWH(700, 0, 100, 50),
        // Target bottom-left corner -> dialog would be at (-100, 600).
        const Offset(0, 580): const Rect.fromLTWH(0, 550, 100, 50),
        // Target bottom-right corner -> dialog would be at (800, 600).
        const Offset(760, 580): const Rect.fromLTWH(700, 550, 100, 50),
        // Near the left edge only -> only x is adjusted (from -90).
        const Offset(10, 290): const Rect.fromLTWH(0, 275, 100, 50),
        // Near the bottom edge only -> only y is adjusted (from 590).
        const Offset(380, 570): const Rect.fromLTWH(350, 550, 100, 50),
      };

      for (final MapEntry<Offset, Rect> entry in cases.entries) {
        await pumpTarget(tester, targetTopLeft: entry.key);
        // Pick anchors that push the dialog away from the closest corner.
        final Offset targetCenter = entry.key + kTargetSize.center(Offset.zero);
        final Alignment followerAnchor = Alignment(
          targetCenter.dx < 100
              ? 1
              : targetCenter.dx > 700
                  ? -1
                  : 0,
          targetCenter.dy < 100
              ? 1
              : targetCenter.dy > 500
                  ? -1
                  : 0,
        );
        final Alignment targetAnchor = Alignment(
          -followerAnchor.x,
          -followerAnchor.y,
        );
        await open<void>(
          tester,
          (BuildContext context) => showAlignedDialog(
            context: context,
            builder: dialogBuilder(),
            followerAnchor: followerAnchor,
            targetAnchor: targetAnchor,
            avoidOverflow: true,
          ),
        );
        expect(dialogRect(tester), entry.value, reason: 'target ${entry.key}');
        await closeDialog(tester);
      }
    });

    testWidgets('avoidOverflow does not move a dialog that fits', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.topLeft,
          targetAnchor: Alignment.bottomLeft,
          avoidOverflow: true,
        ),
      );

      expect(dialogRect(tester), const Rect.fromLTWH(380, 310, 100, 50));
    });

    testWidgets('avoidOverflow also applies to the offset', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          offset: const Offset(1000, -1000),
          avoidOverflow: true,
        ),
      );

      expect(dialogRect(tester), const Rect.fromLTWH(700, 0, 100, 50));
    });

    testWidgets('a dialog larger than the screen is constrained to it', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester, targetTopLeft: Offset.zero);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(size: const Size(1000, 1000)),
        ),
      );
      // Constrained to 800x600 and centered on the target center (20, 10).
      expect(dialogRect(tester), const Rect.fromLTWH(-380, -290, 800, 600));
      await closeDialog(tester);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(size: const Size(1000, 1000)),
          avoidOverflow: true,
        ),
      );
      expect(dialogRect(tester), const Rect.fromLTWH(0, 0, 800, 600));
    });

    testWidgets(
      'the vertical safe area limits the dialog height but avoidOverflow '
      'uses the whole screen',
      (WidgetTester tester) async {
        setUpView(
          tester,
          padding: const FakeViewPadding(top: 24, bottom: 34, left: 10),
        );
        await pumpTarget(tester, targetTopLeft: Offset.zero);

        await open<void>(
          tester,
          (BuildContext context) => showAlignedDialog(
            context: context,
            builder: dialogBuilder(size: const Size(1000, 1000)),
            avoidOverflow: true,
          ),
        );
        // 600 - 24 - 34 = 542; horizontal padding is not applied.
        expect(dialogRect(tester), const Rect.fromLTWH(0, 0, 800, 542));
        await closeDialog(tester);

        await open<void>(
          tester,
          (BuildContext context) => showAlignedDialog(
            context: context,
            builder: dialogBuilder(),
            followerAnchor: Alignment.topLeft,
            targetAnchor: Alignment.bottomLeft,
          ),
        );
        // Local dialogs are not shifted by the safe area.
        expect(dialogRect(tester), const Rect.fromLTWH(0, 20, 100, 50));
      },
    );

    testWidgets('handles a zero-size target', (WidgetTester tester) async {
      setUpView(tester);
      await pumpTarget(
        tester,
        targetTopLeft: const Offset(100, 100),
        targetSize: Size.zero,
      );

      for (final Alignment targetAnchor in kAnchors) {
        await open<void>(
          tester,
          (BuildContext context) => showAlignedDialog(
            context: context,
            builder: dialogBuilder(),
            followerAnchor: Alignment.topLeft,
            targetAnchor: targetAnchor,
          ),
        );
        expect(dialogRect(tester), const Rect.fromLTWH(100, 100, 100, 50));
        await closeDialog(tester);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles off-screen targets', (WidgetTester tester) async {
      setUpView(tester);

      await pumpTarget(tester, targetTopLeft: const Offset(-300, -200));
      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.topLeft,
          targetAnchor: Alignment.bottomLeft,
        ),
      );
      expect(dialogRect(tester), const Rect.fromLTWH(-300, -180, 100, 50));
      await closeDialog(tester);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.topLeft,
          targetAnchor: Alignment.bottomLeft,
          avoidOverflow: true,
        ),
      );
      expect(dialogRect(tester), const Rect.fromLTWH(0, 0, 100, 50));
      await closeDialog(tester);

      await pumpTarget(tester, targetTopLeft: const Offset(1000, 900));
      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          avoidOverflow: true,
        ),
      );
      expect(dialogRect(tester), const Rect.fromLTWH(700, 550, 100, 50));
      expect(tester.takeException(), isNull);
    });

    testWidgets('follows the current scroll position of the target', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: ListView(
            children: <Widget>[
              for (int i = 0; i < 30; i++)
                SizedBox(
                  key: i == 10 ? kTargetKey : null,
                  height: 100,
                  child: Text('Item $i'),
                ),
            ],
          ),
        ),
      );
      await tester.drag(find.byType(ListView), const Offset(0, -650));
      await tester.pumpAndSettle();
      final Rect targetRect = tester.getRect(find.byKey(kTargetKey));
      expect(targetRect, const Rect.fromLTWH(0, 350, 800, 100));

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.bottomRight,
          targetAnchor: Alignment.topRight,
        ),
      );

      expect(dialogRect(tester), const Rect.fromLTWH(700, 300, 100, 50));
    });

    testWidgets('respects transforms applied to the target', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: Transform.scale(
              scale: 2,
              child: const SizedBox(key: kTargetKey, width: 40, height: 20),
            ),
          ),
        ),
      );
      // The painted target covers (360, 280) - (440, 320).

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.topLeft,
          targetAnchor: Alignment.bottomRight,
        ),
      );

      expect(dialogRect(tester), const Rect.fromLTWH(440, 320, 100, 50));
    });

    testWidgets('anchors are not mirrored in right-to-left layouts', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester, textDirection: TextDirection.rtl);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.topLeft,
          targetAnchor: Alignment.bottomLeft,
          offset: const Offset(5, 0),
        ),
      );

      expect(
        Directionality.of(tester.element(find.byKey(kDialogKey))),
        TextDirection.rtl,
      );
      expect(dialogRect(tester), const Rect.fromLTWH(385, 310, 100, 50));
    });

    testWidgets(
        'positions correctly when the target is in a nested '
        'navigator that is offset from the screen origin', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      final GlobalKey<NavigatorState> nestedNavigator =
          GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: <Widget>[
              Positioned(
                left: 100,
                top: 80,
                width: 500,
                height: 400,
                child: Navigator(
                  key: nestedNavigator,
                  onGenerateRoute: (RouteSettings settings) =>
                      PageRouteBuilder<void>(
                    pageBuilder: (_, __, ___) => const Stack(
                      children: <Widget>[
                        Positioned(
                          left: 50,
                          top: 60,
                          width: 40,
                          height: 20,
                          child: SizedBox(key: kTargetKey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      const Rect targetRect = Rect.fromLTWH(150, 140, 40, 20);
      expect(tester.getRect(find.byKey(kTargetKey)), targetRect);

      for (final bool useRootNavigator in <bool>[true, false]) {
        await open<void>(
          tester,
          (BuildContext context) => showAlignedDialog(
            context: context,
            builder: dialogBuilder(),
            followerAnchor: Alignment.topLeft,
            targetAnchor: Alignment.bottomLeft,
            useRootNavigator: useRootNavigator,
          ),
        );
        expect(
          dialogRect(tester),
          const Rect.fromLTWH(150, 160, 100, 50),
          reason: 'useRootNavigator: $useRootNavigator',
        );
        final NavigatorState dialogNavigator =
            Navigator.of(tester.element(find.byKey(kDialogKey)));
        expect(
          identical(dialogNavigator, nestedNavigator.currentState),
          !useRootNavigator,
        );
        await closeDialog(tester);
      }
    });
  });

  group('showAlignedDialog isGlobal', () {
    testWidgets('aligns the dialog to the screen and ignores the target', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester, targetTopLeft: const Offset(30, 500));
      final Rect screen = Offset.zero & kScreenSize;

      for (final Alignment followerAnchor in kAnchors) {
        await open<void>(
          tester,
          (BuildContext context) => showAlignedDialog(
            context: context,
            builder: dialogBuilder(),
            followerAnchor: followerAnchor,
            targetAnchor: Alignment.bottomRight,
            isGlobal: true,
          ),
        );
        expect(
          dialogRect(tester),
          followerAnchor.inscribe(kDialogSize, screen),
          reason: 'follower: $followerAnchor',
        );
        await closeDialog(tester);
      }
    });

    testWidgets('applies offset and avoidOverflow', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.topRight,
          offset: const Offset(-10, 20),
          isGlobal: true,
        ),
      );
      expect(dialogRect(tester), const Rect.fromLTWH(690, 20, 100, 50));
      await closeDialog(tester);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.topRight,
          offset: const Offset(50, -20),
          isGlobal: true,
          avoidOverflow: true,
        ),
      );
      expect(dialogRect(tester), const Rect.fromLTWH(700, 0, 100, 50));
    });

    testWidgets('aligns the dialog inside the safe area', (
      WidgetTester tester,
    ) async {
      setUpView(
        tester,
        padding: const FakeViewPadding(
          left: 10,
          top: 24,
          right: 20,
          bottom: 34,
        ),
      );
      await pumpTarget(tester);
      // The safe area is (10, 24) - (780, 566).
      const Rect safeArea = Rect.fromLTRB(10, 24, 780, 566);

      for (final Alignment followerAnchor in kAnchors.take(9)) {
        await open<void>(
          tester,
          (BuildContext context) => showAlignedDialog(
            context: context,
            builder: dialogBuilder(),
            followerAnchor: followerAnchor,
            isGlobal: true,
          ),
        );
        expect(
          dialogRect(tester),
          followerAnchor.inscribe(kDialogSize, safeArea),
          reason: 'follower: $followerAnchor',
        );
        // The safe area is consumed, like SafeArea does.
        expect(
          MediaQuery.paddingOf(tester.element(find.byKey(kDialogKey))),
          EdgeInsets.zero,
        );
        await closeDialog(tester);
      }

      // A dialog that is too large is limited to the safe area.
      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(size: const Size(1000, 1000)),
          followerAnchor: Alignment.bottomLeft,
          isGlobal: true,
          avoidOverflow: true,
        ),
      );
      expect(dialogRect(tester), safeArea);
    });

    testWidgets('keeps the alignment when the screen size changes', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);
      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.bottomRight,
          isGlobal: true,
        ),
      );
      expect(dialogRect(tester), const Rect.fromLTWH(700, 550, 100, 50));

      tester.view.physicalSize = const Size(600, 800);
      await tester.pumpAndSettle();

      expect(dialogRect(tester), const Rect.fromLTWH(500, 750, 100, 50));
    });

    testWidgets('aligns to the screen when called from a nested navigator', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      final GlobalKey<NavigatorState> nestedNavigator =
          GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: <Widget>[
              Positioned(
                left: 100,
                top: 80,
                width: 500,
                height: 400,
                child: Navigator(
                  key: nestedNavigator,
                  onGenerateRoute: (RouteSettings settings) =>
                      PageRouteBuilder<void>(
                    pageBuilder: (_, __, ___) =>
                        const SizedBox(key: kTargetKey),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.bottomRight,
          isGlobal: true,
        ),
      );
      // Pushed on the root navigator: aligned to the whole screen.
      expect(dialogRect(tester), const Rect.fromLTWH(700, 550, 100, 50));
      await closeDialog(tester);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.bottomRight,
          isGlobal: true,
          useRootNavigator: false,
        ),
      );
      // Pushed on the nested navigator: aligned to that navigator.
      expect(dialogRect(tester), const Rect.fromLTWH(500, 430, 100, 50));
    });
  });

  group('showGlobalDrawer', () {
    const Size drawerSize = Size(200, 300);

    final Map<AxisDirection, Rect> expectedRects = <AxisDirection, Rect>{
      AxisDirection.left: const Rect.fromLTWH(0, 0, 200, 300),
      AxisDirection.right: const Rect.fromLTWH(600, 0, 200, 300),
      AxisDirection.up: const Rect.fromLTWH(0, 0, 200, 300),
      AxisDirection.down: const Rect.fromLTWH(0, 300, 200, 300),
    };

    for (final AxisDirection direction in AxisDirection.values) {
      testWidgets('slides in from the $direction edge', (
        WidgetTester tester,
      ) async {
        setUpView(tester);
        await pumpTarget(tester);

        final DialogResult<String> result = DialogResult<String>(
          showGlobalDrawer<String>(
            context: tester.element(find.byKey(kTargetKey)),
            builder: dialogBuilder(size: drawerSize),
            direction: direction,
          ),
        );
        await tester.pump();
        final Rect end = expectedRects[direction]!;

        // The slide is linear and relative to the size of the whole page
        // (800x600), not to the size of the drawer.
        await tester.pump(const Duration(milliseconds: 100));
        final Offset halfWay = switch (direction) {
          AxisDirection.left => const Offset(-400, 0),
          AxisDirection.right => const Offset(400, 0),
          AxisDirection.up => const Offset(0, -300),
          AxisDirection.down => const Offset(0, 300),
        };
        expect(dialogRect(tester), end.shift(halfWay));

        await tester.pumpAndSettle();
        expect(dialogRect(tester), end);
        expect(result.completed, isFalse);

        // The default barrier dismisses the drawer.
        final ModalBarrier barrier =
            tester.widget<ModalBarrier>(find.byType(ModalBarrier).last);
        expect(barrier.color, Colors.black54);
        expect(barrier.dismissible, isTrue);
        await tester.tapAt(
          direction == AxisDirection.right
              ? const Offset(100, 500)
              : const Offset(700, 100),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(kDialogKey), findsNothing);
        expect(result.completed, isTrue);
        expect(result.value, isNull);
      });
    }

    testWidgets('stays inside the safe area', (WidgetTester tester) async {
      setUpView(
        tester,
        padding: const FakeViewPadding(top: 24, bottom: 34),
      );
      await pumpTarget(tester);

      for (final AxisDirection direction in AxisDirection.values) {
        showGlobalDrawer<void>(
          context: tester.element(find.byKey(kTargetKey)),
          builder: dialogBuilder(size: drawerSize),
          direction: direction,
        );
        await tester.pumpAndSettle();
        final Rect expected = switch (direction) {
          AxisDirection.left => const Rect.fromLTWH(0, 24, 200, 300),
          AxisDirection.right => const Rect.fromLTWH(600, 24, 200, 300),
          AxisDirection.up => const Rect.fromLTWH(0, 24, 200, 300),
          AxisDirection.down => const Rect.fromLTWH(0, 266, 200, 300),
        };
        expect(dialogRect(tester), expected, reason: '$direction');
        await closeDialog(tester);
      }
    });

    testWidgets('forwards the barrier and route options', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);

      final DialogResult<int> result = await open<int>(
        tester,
        (BuildContext context) => showGlobalDrawer<int>(
          context: context,
          builder: dialogBuilder(size: drawerSize),
          barrierDismissible: false,
          barrierColor: const Color(0x11223344),
          barrierLabel: 'Close drawer',
          routeSettings: const RouteSettings(name: 'drawer'),
          duration: const Duration(seconds: 1),
        ),
      );
      final ModalBarrier barrier =
          tester.widget<ModalBarrier>(find.byType(ModalBarrier).last);
      expect(barrier.color, const Color(0x11223344));
      expect(barrier.semanticsLabel, 'Close drawer');
      expect(
        ModalRoute.of(tester.element(find.byKey(kDialogKey)))!.settings.name,
        'drawer',
      );

      await tester.tapAt(const Offset(700, 500));
      await tester.pumpAndSettle();
      expect(find.byKey(kDialogKey), findsOneWidget);

      Navigator.of(tester.element(find.byKey(kDialogKey))).pop(7);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.byKey(kDialogKey), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 101));
      await tester.pump();
      expect(find.byKey(kDialogKey), findsNothing);
      expect(result.value, 7);
    });
  });

  group('barrier', () {
    testWidgets('defaults to a dismissible black54 barrier', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);

      final DialogResult<String> result = await open<String>(
        tester,
        (BuildContext context) => showAlignedDialog<String>(
          context: context,
          builder: dialogBuilder(),
        ),
      );
      final ModalBarrier barrier =
          tester.widget<ModalBarrier>(find.byType(ModalBarrier).last);
      expect(barrier.color, Colors.black54);
      expect(barrier.dismissible, isTrue);
      expect(barrier.semanticsLabel, 'Dismiss');

      // Tapping the dialog itself does not dismiss it.
      await tester.tap(find.byKey(kDialogKey));
      await tester.pumpAndSettle();
      expect(find.byKey(kDialogKey), findsOneWidget);

      // Tapping outside of it does.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byKey(kDialogKey), findsNothing);
      expect(result.completed, isTrue);
      expect(result.value, isNull);
    });

    testWidgets('barrierDismissible: false keeps the dialog open', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);

      final DialogResult<String> result = await open<String>(
        tester,
        (BuildContext context) => showAlignedDialog<String>(
          context: context,
          builder: dialogBuilder(),
          barrierDismissible: false,
        ),
      );
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byKey(kDialogKey), findsOneWidget);
      expect(result.completed, isFalse);

      await closeDialog(tester, 'done');
      expect(result.value, 'done');
    });

    testWidgets('uses the given barrier color and label', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          barrierColor: const Color(0x40FF0000),
          barrierLabel: 'Close me',
        ),
      );
      ModalBarrier barrier =
          tester.widget<ModalBarrier>(find.byType(ModalBarrier).last);
      expect(barrier.color, const Color(0x40FF0000));
      expect(barrier.semanticsLabel, 'Close me');
      await closeDialog(tester);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          barrierColor: null,
        ),
      );
      barrier = tester.widget<ModalBarrier>(find.byType(ModalBarrier).last);
      expect(barrier.color, isNull);
      expect(barrier.dismissible, isTrue);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byKey(kDialogKey), findsNothing);
    });
  });

  group('route', () {
    testWidgets('the future completes with the value passed to pop', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);

      final DialogResult<int> result = await open<int>(
        tester,
        (BuildContext context) => showAlignedDialog<int>(
          context: context,
          builder: dialogBuilder(),
        ),
      );
      expect(result.completed, isFalse);
      await closeDialog(tester, 42);
      expect(result.completed, isTrue);
      expect(result.value, 42);
    });

    testWidgets('the system back button closes the dialog', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);

      final DialogResult<int> result = await open<int>(
        tester,
        (BuildContext context) => showAlignedDialog<int>(
          context: context,
          builder: dialogBuilder(),
          barrierDismissible: false,
        ),
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(kDialogKey), findsNothing);
      expect(result.completed, isTrue);
      expect(result.value, isNull);
    });

    testWidgets('passes route settings and pushes a transparent popup route', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);

      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: dialogBuilder(),
          routeSettings: const RouteSettings(name: 'aligned', arguments: 3),
        ),
      );
      final ModalRoute<Object?> route =
          ModalRoute.of(tester.element(find.byKey(kDialogKey)))!;
      expect(route, isA<AlignedDialogRoute<void>>());
      expect(route, isA<RawDialogRoute<void>>());
      expect(route.settings.name, 'aligned');
      expect(route.settings.arguments, 3);
      expect(route.opaque, isFalse);
      // The page below stays visible.
      expect(find.byKey(kTargetKey), findsOneWidget);
    });

    testWidgets('captures the themes of the target context', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: Theme(
              data: ThemeData(primaryColor: const Color(0xFF123456)),
              child: const DefaultTextStyle(
                style: TextStyle(fontSize: 42),
                child: SizedBox(key: kTargetKey, width: 40, height: 20),
              ),
            ),
          ),
        ),
      );

      late BuildContext dialogContext;
      await open<void>(
        tester,
        (BuildContext context) => showAlignedDialog(
          context: context,
          builder: (BuildContext context) {
            dialogContext = context;
            return dialogBuilder()(context);
          },
        ),
      );
      expect(Theme.of(dialogContext).primaryColor, const Color(0xFF123456));
      expect(DefaultTextStyle.of(dialogContext).style.fontSize, 42);
    });

    testWidgets('AlignedDialogRoute can be pushed directly', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);
      final BuildContext context = tester.element(find.byKey(kTargetKey));

      final DialogResult<bool> result = DialogResult<bool>(
        Navigator.of(context).push(
          AlignedDialogRoute<bool>(
            context: context,
            builder: dialogBuilder(),
            followerAlignment: Alignment.bottomRight,
            position: const Offset(200, 100),
            offset: const Offset(5, 5),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(dialogRect(tester), const Rect.fromLTWH(105, 55, 100, 50));
      final ModalBarrier barrier =
          tester.widget<ModalBarrier>(find.byType(ModalBarrier).last);
      // The route's own default barrier color is transparent, so the barrier
      // is not painted at all.
      expect(barrier.color, isNull);
      expect(barrier.dismissible, isTrue);

      await closeDialog(tester, true);
      expect(result.value, isTrue);
    });

    testWidgets('AlignedDialogRoute with useSafeArea lays out in the safe area',
        (WidgetTester tester) async {
      setUpView(tester, padding: const FakeViewPadding(top: 24, left: 10));
      await pumpTarget(tester);
      final BuildContext context = tester.element(find.byKey(kTargetKey));

      Navigator.of(context).push(
        AlignedDialogRoute<void>(
          context: context,
          builder: dialogBuilder(),
          followerAlignment: Alignment.topLeft,
          position: const Offset(200, 100),
          useSafeArea: true,
        ),
      );
      await tester.pumpAndSettle();
      // The position is relative to the safe area.
      expect(dialogRect(tester), const Rect.fromLTWH(210, 124, 100, 50));
    });
  });

  group('transitions', () {
    testWidgets('fades in and out with an ease-out curve over 200ms', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);
      final BuildContext context = tester.element(find.byKey(kTargetKey));

      double opacity() => tester
          .widget<FadeTransition>(
            find
                .ancestor(
                  of: find.byKey(kDialogKey),
                  matching: find.byType(FadeTransition),
                )
                .first,
          )
          .opacity
          .value;

      showAlignedDialog<void>(context: context, builder: dialogBuilder());
      await tester.pump();
      expect(opacity(), 0.0);
      await tester.pump(const Duration(milliseconds: 100));
      expect(opacity(), moreOrLessEquals(Curves.easeOut.transform(0.5)));
      await tester.pump(const Duration(milliseconds: 100));
      expect(opacity(), 1.0);
      await tester.pumpAndSettle();
      // The position does not change while animating.
      expect(dialogRect(tester), const Rect.fromLTWH(350, 275, 100, 50));

      Navigator.of(tester.element(find.byKey(kDialogKey))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(opacity(), moreOrLessEquals(Curves.easeOut.transform(0.5)));
      await tester.pump(const Duration(milliseconds: 101));
      await tester.pump();
      expect(find.byKey(kDialogKey), findsNothing);
    });

    testWidgets('honors the duration', (WidgetTester tester) async {
      setUpView(tester);
      await pumpTarget(tester);
      final BuildContext context = tester.element(find.byKey(kTargetKey));

      showAlignedDialog<void>(
        context: context,
        builder: dialogBuilder(),
        duration: const Duration(seconds: 1),
      );
      await tester.pump();
      final Animation<double> animation =
          ModalRoute.of(tester.element(find.byKey(kDialogKey)))!.animation!;
      await tester.pump(const Duration(milliseconds: 500));
      expect(animation.value, moreOrLessEquals(0.5));
      expect(animation.status, AnimationStatus.forward);
      await tester.pump(const Duration(milliseconds: 501));
      expect(animation.status, AnimationStatus.completed);
    });

    testWidgets('uses a custom transitionsBuilder', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);
      final BuildContext context = tester.element(find.byKey(kTargetKey));
      const Key transitionKey = Key('transition');

      showAlignedDialog<void>(
        context: context,
        builder: dialogBuilder(),
        transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return ScaleTransition(
            key: transitionKey,
            scale: animation,
            child: child,
          );
        },
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester.widget<ScaleTransition>(find.byKey(transitionKey)).scale.value,
        moreOrLessEquals(0.5),
      );
      // The default fade is replaced, not combined.
      expect(
        find.ancestor(
          of: find.byKey(kDialogKey),
          matching: find.byType(FadeTransition),
        ),
        findsNothing,
      );
      await tester.pumpAndSettle();
      expect(dialogRect(tester), const Rect.fromLTWH(350, 275, 100, 50));
    });

    testWidgets('does not leak CurvedAnimations', (WidgetTester tester) async {
      setUpView(tester);
      await pumpTarget(tester);

      final Set<Object> undisposed = <Object>{};
      void listener(ObjectEvent event) {
        if (event.object is! CurvedAnimation) {
          return;
        }
        if (event is ObjectCreated) {
          undisposed.add(event.object);
        } else if (event is ObjectDisposed) {
          undisposed.remove(event.object);
        }
      }

      FlutterMemoryAllocations.instance.addListener(listener);
      addTearDown(
        () => FlutterMemoryAllocations.instance.removeListener(listener),
      );

      await open<void>(
        tester,
        (BuildContext context) =>
            showAlignedDialog(context: context, builder: dialogBuilder()),
      );
      await closeDialog(tester);
      await open<void>(
        tester,
        (BuildContext context) => showGlobalDrawer(
          context: context,
          builder: dialogBuilder(),
        ),
      );
      await closeDialog(tester);

      expect(undisposed, isEmpty);
    });
  });

  group('context', () {
    testWidgets('the dialog survives removal of the target', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      final ValueNotifier<bool> showTarget = ValueNotifier<bool>(true);
      addTearDown(showTarget.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<bool>(
            valueListenable: showTarget,
            builder: (BuildContext context, bool show, Widget? child) => Stack(
              children: <Widget>[
                if (show)
                  const Positioned(
                    left: 380,
                    top: 290,
                    width: 40,
                    height: 20,
                    child: SizedBox(key: kTargetKey),
                  ),
              ],
            ),
          ),
        ),
      );

      final DialogResult<String> result = await open<String>(
        tester,
        (BuildContext context) => showAlignedDialog<String>(
          context: context,
          builder: dialogBuilder(),
          followerAnchor: Alignment.topLeft,
          targetAnchor: Alignment.bottomLeft,
        ),
      );

      showTarget.value = false;
      await tester.pumpAndSettle();
      expect(find.byKey(kTargetKey), findsNothing);
      expect(dialogRect(tester), const Rect.fromLTWH(380, 310, 100, 50));

      await closeDialog(tester, 'bye');
      expect(result.value, 'bye');
    });

    testWidgets('throws a helpful error for an unmounted context', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await pumpTarget(tester);
      final BuildContext staleContext = tester.element(find.byKey(kTargetKey));
      // Unmount the whole tree that contained the target.
      await tester.pumpWidget(const SizedBox());
      expect(staleContext.mounted, isFalse);

      expect(
        () => showAlignedDialog<void>(
          context: staleContext,
          builder: dialogBuilder(),
        ),
        throwsA(
          isA<FlutterError>().having(
            (FlutterError error) => error.message,
            'message',
            contains('This BuildContext is no longer valid'),
          ),
        ),
      );
    });

    testWidgets('isGlobal does not need a laid out box as the context', (
      WidgetTester tester,
    ) async {
      setUpView(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Builder(
                  builder: (BuildContext context) =>
                      const SizedBox(height: 100),
                ),
              ),
            ],
          ),
        ),
      );
      // The context of the sliver itself has a RenderSliver, not a RenderBox.
      final BuildContext sliverContext =
          tester.element(find.byType(SliverToBoxAdapter));
      expect(sliverContext.findRenderObject(), isA<RenderSliver>());

      showAlignedDialog<void>(
        context: sliverContext,
        builder: dialogBuilder(),
        isGlobal: true,
      );
      await tester.pumpAndSettle();
      expect(dialogRect(tester), const Rect.fromLTWH(350, 275, 100, 50));
    });
  });
}
