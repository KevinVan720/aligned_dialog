import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shows a dialog that is aligned to the widget that opens it.
///
/// The dialog is positioned relative to the render box of [context], so
/// [context] should be the [BuildContext] of the widget the dialog is attached
/// to (for example, obtained with a [Builder] around a button), not the
/// context of a whole page.
///
/// The [followerAnchor] and [targetAnchor] tell how the dialog and the widget
/// of [context] are aligned, similar to [CompositedTransformFollower]: the
/// [followerAnchor] point of the dialog is placed on the [targetAnchor] point
/// of the target widget. For example, `followerAnchor: Alignment.topLeft` and
/// `targetAnchor: Alignment.bottomLeft` open the dialog right below the
/// target, with their left edges aligned. Both anchors are physical
/// [Alignment]s, so they are not mirrored in right-to-left layouts.
///
/// The [offset] is added to the dialog position after aligning it, for
/// additional fine control over how the dialog is positioned.
///
/// If [avoidOverflow] is true, the dialog is shifted as little as possible to
/// keep it inside the bounds of the navigator it is shown in, instead of being
/// painted (partially) outside of the screen.
///
/// If [isGlobal] is true, the dialog is aligned relative to the whole screen
/// (more precisely, to the safe area of the navigator the dialog is pushed
/// onto) instead of the target widget. In that case [followerAnchor] is used
/// for both the dialog and the screen, and [targetAnchor] is ignored. For
/// example, `followerAnchor: Alignment.bottomCenter` shows the dialog at the
/// bottom center of the screen.
///
/// The [transitionsBuilder] tells how the dialog shows up and dismisses. The
/// default is a fade transition with an ease-out curve. The [duration]
/// specifies how long this transition takes, and defaults to 200
/// milliseconds.
///
/// The [barrierDismissible], [barrierColor] and [barrierLabel] arguments
/// configure the [ModalBarrier] that is shown behind the dialog. By default,
/// tapping the barrier dismisses the dialog, the barrier is [Colors.black54]
/// and its semantic label is
/// [MaterialLocalizations.modalBarrierDismissLabel].
///
/// The [useRootNavigator] argument is used to determine whether to push the
/// dialog to the [Navigator] furthest from or nearest to the given [context].
/// By default, the dialog is pushed onto the root navigator.
///
/// The [routeSettings] are passed to the [AlignedDialogRoute] that is pushed.
///
/// The [builder] builds the content of the dialog. It does not share a context
/// with the location that [showAlignedDialog] is originally called from, so use
/// a [StatefulBuilder] or a custom [StatefulWidget] if the dialog needs to
/// update dynamically. The dialog content is laid out with loose constraints,
/// at most as large as the screen, and is aligned using its own size. Content
/// that expands to fill the available space (such as a [Dialog]) takes the
/// whole screen.
///
/// The [context] is only used when this function is called. Its widget can
/// safely be removed from the tree while the dialog is open. The dialog keeps
/// the position that the target had when the dialog was opened.
///
/// Returns a [Future] that resolves to the value (if any) that was passed to
/// [Navigator.pop] when the dialog was closed.
///
/// See also:
///
///  * [showGlobalDrawer], which shows a dialog that slides in from an edge of
///    the screen.
///  * [AlignedDialogRoute], the route used by this function.
///  * [showDialog], which shows a dialog in the center of the screen.
Future<T?> showAlignedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor = Colors.black54,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Alignment followerAnchor = Alignment.center,
  Alignment targetAnchor = Alignment.center,
  Offset offset = Offset.zero,
  bool avoidOverflow = false,
  bool isGlobal = false,
  RouteTransitionsBuilder? transitionsBuilder,
  Duration? duration,
}) {
  assert(_debugIsActive(context));
  assert(debugCheckHasMaterialLocalizations(context));

  final NavigatorState navigator = Navigator.of(
    context,
    rootNavigator: useRootNavigator,
  );
  final CapturedThemes themes = InheritedTheme.capture(
    from: context,
    to: navigator.context,
  );

  return navigator.push<T>(
    AlignedDialogRoute<T>._(
      context: context,
      builder: builder,
      followerAlignment: followerAnchor,
      // Global dialogs are aligned to the bounds of the route itself, see
      // _AlignedDialogLayout.
      position:
          isGlobal ? null : _targetPosition(context, navigator, targetAnchor),
      themes: themes,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      useSafeArea: isGlobal,
      settings: routeSettings,
      transitionsBuilder: transitionsBuilder,
      duration: duration,
      avoidOverflow: avoidOverflow,
      offset: offset,
    ),
  );
}

/// The [targetAnchor] point of the render box of [context], in the coordinate
/// space of the overlay of [navigator], which is where the dialog route is laid
/// out.
Offset _targetPosition(
  BuildContext context,
  NavigatorState navigator,
  Alignment targetAnchor,
) {
  final RenderObject? target = context.findRenderObject();
  assert(
    target is RenderBox && target.hasSize,
    'showAlignedDialog needs the context of a widget that has a laid out '
    'RenderBox to align the dialog to, but the render object of the given '
    'context is $target. Pass the BuildContext of the target widget (for '
    'example from a Builder wrapping it), or set isGlobal to true.',
  );
  final RenderBox targetBox = target! as RenderBox;
  final RenderBox overlay =
      navigator.overlay!.context.findRenderObject()! as RenderBox;
  return targetBox.localToGlobal(
    targetAnchor.alongSize(targetBox.size),
    ancestor: overlay,
  );
}

bool _debugIsActive(BuildContext context) {
  if (context is Element && !context.debugIsActive) {
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary('This BuildContext is no longer valid.'),
      ErrorDescription(
        'The context parameter of showAlignedDialog is a BuildContext that is '
        'no longer valid.',
      ),
      ErrorHint(
        'This can commonly occur when showAlignedDialog is called after '
        'awaiting a Future. In this situation the BuildContext might refer to '
        'a widget that has already been disposed during the await. Check '
        '"context.mounted" before showing the dialog.',
      ),
    ]);
  }
  return true;
}

/// A dialog route that positions its content at a given point.
///
/// This is the route that [showAlignedDialog] pushes. The dialog content built
/// by `builder` is laid out with loose constraints and positioned so that its
/// `followerAlignment` point lands on `position`, shifted by `offset`.
///
/// It has a modal barrier (by default transparent and dismissible) and fades
/// in and out unless a custom `transitionsBuilder` is given.
class AlignedDialogRoute<T> extends RawDialogRoute<T> {
  /// Creates a dialog route whose content is aligned to `position`.
  ///
  /// The `context` is used to look up the default `barrierLabel`
  /// ([MaterialLocalizations.modalBarrierDismissLabel]), so it needs to have
  /// [MaterialLocalizations] when `barrierLabel` is null. It is not used after
  /// the constructor returns.
  ///
  /// The `builder` builds the content of the dialog.
  ///
  /// The `followerAlignment` point of the dialog is placed on `position`, which
  /// is in the coordinate space of the [Overlay] of the [Navigator] the route
  /// is pushed onto (or of its safe area if `useSafeArea` is true). The
  /// `offset` is added to the resulting position.
  ///
  /// The `themes` are applied to the dialog content. Typically they are
  /// obtained with [InheritedTheme.capture].
  ///
  /// If `useSafeArea` is true, the dialog is laid out inside a [SafeArea].
  ///
  /// If `avoidOverflow` is true, the dialog is shifted to stay inside the
  /// bounds of the route.
  ///
  /// The `transitionsBuilder` defines how the route arrives on and leaves off
  /// the screen; it defaults to a fade transition with an ease-out curve. The
  /// transition takes `duration`, which defaults to 200 milliseconds.
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
    bool avoidOverflow = false,
    Offset offset = Offset.zero,
  }) : this._(
          context: context,
          builder: builder,
          followerAlignment: followerAlignment,
          position: position,
          themes: themes,
          barrierColor: barrierColor,
          barrierDismissible: barrierDismissible,
          barrierLabel: barrierLabel,
          useSafeArea: useSafeArea,
          settings: settings,
          transitionsBuilder: transitionsBuilder,
          duration: duration,
          avoidOverflow: avoidOverflow,
          offset: offset,
        );

  // A null `position` aligns the dialog to the bounds of the route instead of
  // a point (used for global dialogs).
  AlignedDialogRoute._({
    required BuildContext context,
    required WidgetBuilder builder,
    required Alignment followerAlignment,
    required Offset? position,
    required CapturedThemes? themes,
    required super.barrierColor,
    required super.barrierDismissible,
    required String? barrierLabel,
    required bool useSafeArea,
    required super.settings,
    required RouteTransitionsBuilder? transitionsBuilder,
    required Duration? duration,
    required bool avoidOverflow,
    required Offset offset,
  }) : super(
          pageBuilder: (
            BuildContext buildContext,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            final Widget pageChild = Builder(builder: builder);
            Widget dialog = Builder(
              builder: (BuildContext context) {
                final EdgeInsets padding = MediaQuery.paddingOf(context);
                return CustomSingleChildLayout(
                  delegate: _AlignedDialogLayout(
                    followerAnchor: followerAlignment,
                    position: position,
                    offset: offset,
                    avoidOverflow: avoidOverflow,
                    topPadding: padding.top,
                    bottomPadding: padding.bottom,
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
          barrierLabel: barrierLabel ??
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          transitionDuration: duration ?? const Duration(milliseconds: 200),
          transitionBuilder: transitionsBuilder ?? _buildFadeTransition,
        );
}

/// Positions the dialog inside the route.
class _AlignedDialogLayout extends SingleChildLayoutDelegate {
  _AlignedDialogLayout({
    required this.followerAnchor,
    required this.position,
    required this.offset,
    required this.avoidOverflow,
    required this.topPadding,
    required this.bottomPadding,
  });

  /// The point of the dialog that is placed on [position].
  final Alignment followerAnchor;

  /// Where the [followerAnchor] point of the dialog goes, in the coordinate
  /// space of this layout.
  ///
  /// If null, the [followerAnchor] point of the bounds of this layout is used,
  /// which aligns the dialog to those bounds.
  final Offset? position;

  /// Added to the position of the dialog after aligning it.
  final Offset offset;

  /// Whether to shift the dialog so that it stays inside the bounds of this
  /// layout.
  final bool avoidOverflow;

  /// Top padding of the unsafe area, which limits the height of the dialog.
  final double topPadding;

  /// Bottom padding of the unsafe area, which limits the height of the dialog.
  final double bottomPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The dialog can be at most as large as the route, minus the vertical
    // padding of the unsafe area.
    return BoxConstraints.loose(constraints.biggest).deflate(
      EdgeInsets.only(top: topPadding, bottom: bottomPadding),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final Offset anchor = position ?? followerAnchor.alongSize(size);
    final Offset result = anchor - followerAnchor.alongSize(childSize) + offset;
    if (!avoidOverflow) {
      return result;
    }
    // Not using clampDouble: if the dialog is larger than the available space,
    // it is aligned with the right/bottom edge, as it has always been.
    return Offset(
      math.min(math.max(result.dx, 0.0), size.width - childSize.width),
      math.min(math.max(result.dy, 0.0), size.height - childSize.height),
    );
  }

  @override
  bool shouldRelayout(_AlignedDialogLayout oldDelegate) {
    return followerAnchor != oldDelegate.followerAnchor ||
        position != oldDelegate.position ||
        offset != oldDelegate.offset ||
        avoidOverflow != oldDelegate.avoidOverflow ||
        topPadding != oldDelegate.topPadding ||
        bottomPadding != oldDelegate.bottomPadding;
  }
}

// Reused by every transition. Unlike a CurvedAnimation, an animation driven by
// a tween does not need to be disposed.
final Animatable<double> _easeOutTween = CurveTween(curve: Curves.easeOut);

Widget _buildFadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: animation.drive(_easeOutTween),
    child: child,
  );
}
