import 'package:flutter/material.dart';

import 'aligned_dialog.dart';

/// Shows a dialog/drawer that is aligned to one of the edges of the screen and
/// slides in from that edge.
///
/// The [direction] is the edge of the screen that the drawer is attached to:
///
///  * [AxisDirection.left]: the top left corner of the screen.
///  * [AxisDirection.right]: the top right corner of the screen.
///  * [AxisDirection.up]: the top left corner of the screen.
///  * [AxisDirection.down]: the bottom left corner of the screen.
///
/// The drawer is laid out inside the safe area and keeps the size of the
/// widget returned by [builder], so give it a size (for example with a
/// [SizedBox] or a [Drawer]) that matches the direction.
///
/// The drawer fades in while sliding in from the [direction] edge. The
/// transition takes [duration], which defaults to 200 milliseconds.
///
/// The other arguments are passed to [showAlignedDialog], which is called with
/// `isGlobal: true`.
///
/// Returns a [Future] that resolves to the value (if any) that was passed to
/// [Navigator.pop] when the drawer was closed.
Future<T?> showGlobalDrawer<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor = Colors.black54,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  AxisDirection direction = AxisDirection.left,
  Duration? duration,
}) {
  final (Alignment followerAnchor, Offset beginOffset) = switch (direction) {
    AxisDirection.left => (Alignment.topLeft, const Offset(-1, 0)),
    AxisDirection.right => (Alignment.topRight, const Offset(1, 0)),
    AxisDirection.up => (Alignment.topLeft, const Offset(0, -1)),
    AxisDirection.down => (Alignment.bottomLeft, const Offset(0, 1)),
  };
  final Animatable<Offset> slideTween = Tween<Offset>(
    begin: beginOffset,
    end: Offset.zero,
  );
  return showAlignedDialog<T>(
    context: context,
    builder: builder,
    followerAnchor: followerAnchor,
    isGlobal: true,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    duration: duration,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          // Unlike a CurvedAnimation, this does not need to be disposed.
          opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
          child: child,
        ),
      );
    },
  );
}
