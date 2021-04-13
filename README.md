# aligned_dialog

A Flutter package that allows you to open a dialog aligned with it's associating widget.

## Getting Started

You can open a dialog in Flutter using the showDialog function. That dialog is almost always a Dialog widget that is centered on the screen. This behavior is not so desired on large screen devices. This package allows you to align the dialog around the widget that opens it.

Below is the interface of the showAlignedDialog function:

```dart
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
})
```

The last seven parameters are whats different from the built-in showDialog function. The **followerAnchor** and **targetAnchor** tells how the dialog and the original widget should be aligned, similar to the CompositedTransformFollower widget. The **offset** is for additional fine control over how the dialog is positioned.

**avoidOverflow** will shift the dialog as possible as it can to avoid painting the dialog outside of the screen, if set to true.

**isGlobal**, if set to true, will align the dialog relative to the whole screen, rendering the targetAnchor parameter irrelevant.

**transitionsBuilder**, tells how the dialog shows up and dismisses. The default behavior is a fade transtion, but you can add more animations like sliding easily. **duration** specifies how long this transtion takes.

You can find examples in the example folder.
