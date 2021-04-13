import 'package:flutter/material.dart';

Future<T?> showAlignedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Alignment followerAnchor = Alignment.center,
  Alignment targetAnchor = Alignment.center,
  bool isGlobal = false,
  bool barrierDismissible = true,
  Color? barrierColor = Colors.black12,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  RouteTransitionsBuilder? transitionsBuilder,
  Duration? duration,
}) {
  assert(builder != null);
  assert(barrierDismissible != null);
  assert(isGlobal != null);
  assert(useRootNavigator != null);
  assert(debugCheckHasMaterialLocalizations(context));

  final CapturedThemes themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(
      context,
      rootNavigator: useRootNavigator,
    ).context,
  );

  final RenderBox targetBox = context.findRenderObject()! as RenderBox;
  final RenderBox overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  Offset position = targetBox
      .localToGlobal(targetAnchor.alongSize(targetBox.size), ancestor: overlay);

  if (isGlobal) {
    position = overlay.localToGlobal(followerAnchor.alongSize(overlay.size));
  }

  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push<T>(AlignedDialogRoute<T>(
    followerAlignment: followerAnchor,
    position: position,
    context: context,
    builder: builder,
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    useSafeArea: isGlobal,
    settings: routeSettings,
    themes: themes,
    transitionsBuilder: transitionsBuilder,
    duration: duration,
  ));
}

class AlignedDialogRoute<T> extends RawDialogRoute<T> {
  /// A dialog route with Material entrance and exit animations,
  /// modal barrier color, and modal barrier behavior (dialog is dismissible
  /// with a tap on the barrier).
  AlignedDialogRoute({
    required BuildContext context,
    required WidgetBuilder builder,
    required Alignment followerAlignment,
    required Offset position,
    CapturedThemes? themes,
    Color? barrierColor = Colors.transparent,
    bool barrierDismissible = true,
    String? barrierLabel,
    bool useSafeArea = false,
    RouteSettings? settings,
    RouteTransitionsBuilder? transitionsBuilder,
    Duration? duration,
  })  : assert(barrierDismissible != null),
        super(
          pageBuilder: (BuildContext buildContext, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            final Widget pageChild = Builder(builder: builder);
            Widget dialog = Builder(
              builder: (BuildContext context) {
                final MediaQueryData mediaQuery = MediaQuery.of(context);
                return CustomSingleChildLayout(
                  delegate: _FollowerDialogRouteLayout(
                    followerAlignment,
                    position,
                    Directionality.of(context),
                    mediaQuery.padding.top,
                    mediaQuery.padding.bottom,
                  ),
                  child: pageChild,
                );
              },
            );
            dialog = themes?.wrap(dialog) ?? dialog;
            if (useSafeArea) {
              dialog = SafeArea(child: dialog);
            }
            return dialog;
          },
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel ??
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          transitionDuration: duration ?? const Duration(milliseconds: 200),
          transitionBuilder:
              transitionsBuilder ?? _buildMaterialDialogTransitions,
          settings: settings,
        );
}

// Positioning of the menu on the screen.
class _FollowerDialogRouteLayout extends SingleChildLayoutDelegate {
  _FollowerDialogRouteLayout(
    this.followerAnchor,
    this.position,
    this.textDirection,
    this.topPadding,
    this.bottomPadding,
  );

  final Alignment followerAnchor;

  // Rectangle of underlying button, relative to the overlay's dimensions.
  final Offset position;

  // Whether to prefer going to the left or to the right.
  final TextDirection textDirection;

  // Top padding of unsafe area.
  final double topPadding;

  // Bottom padding of unsafe area.
  final double bottomPadding;

  // We put the child wherever position specifies, so long as it will fit within
  // the specified parent size padded (inset) by 8. If necessary, we adjust the
  // child's position so that it fits.

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    return BoxConstraints.loose(constraints.biggest)
        .deflate(EdgeInsets.only(top: topPadding, bottom: bottomPadding));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    Offset rst = followerAnchor.alongSize(childSize);
    rst = position - rst;
    return rst;
  }

  @override
  bool shouldRelayout(_FollowerDialogRouteLayout oldDelegate) {
    // If called when the old and new itemSizes have been initialized then
    // we expect them to have the same length because there's no practical
    // way to change length of the items list once the menu has been shown.

    return followerAnchor != oldDelegate.followerAnchor ||
        position != oldDelegate.position ||
        textDirection != oldDelegate.textDirection ||
        topPadding != oldDelegate.topPadding ||
        bottomPadding != oldDelegate.bottomPadding;
  }
}

Widget _buildMaterialDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ),
    child: child,
  );
}
