# aligned_dialog

A Flutter package that allows you to open a dialog aligned with its associated widget.

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

The last seven parameters are what's different from the built-in showDialog function. The **followerAnchor** and **targetAnchor** tell how the dialog and the original widget should be aligned, similar to the CompositedTransformFollower widget: the followerAnchor point of the dialog is placed on the targetAnchor point of the widget. The **offset** is for additional fine control over how the dialog is positioned.

**avoidOverflow** will shift the dialog as little as possible to avoid painting the dialog outside of the screen, if set to true.

**isGlobal**, if set to true, will align the dialog relative to the whole screen (inside its safe area), rendering the targetAnchor parameter irrelevant.

**transitionsBuilder** tells how the dialog shows up and dismisses. The default behavior is a fade transition, but you can add more animations like sliding easily. **duration** specifies how long this transition takes.

The dialog is aligned to the widget of the `context` that you pass, so use the context of the widget that opens the dialog, for example with a `Builder`:

```dart
Builder(
  builder: (BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final String? result = await showAlignedDialog<String>(
          context: context,
          builder: (BuildContext context) => TextButton(
            onPressed: () => Navigator.of(context).pop('Hello'),
            child: const Text('Close'),
          ),
          // Open the dialog right below the button, left edges aligned.
          followerAnchor: Alignment.topLeft,
          targetAnchor: Alignment.bottomLeft,
          avoidOverflow: true,
        );
        debugPrint('Dialog closed with $result');
      },
      child: const Text('Show dialog'),
    );
  },
)
```

To show a drawer that slides in from one of the edges of the screen, use `showGlobalDrawer`:

```dart
showGlobalDrawer(
  context: context,
  builder: (BuildContext context) => const Drawer(child: Text('Drawer')),
  direction: AxisDirection.right,
);
```

You can find more examples in the example folder.

![example1](https://i.imgur.com/y7OFoJ8.gif)

![example2](https://i.imgur.com/wbBSpwy.gif)
