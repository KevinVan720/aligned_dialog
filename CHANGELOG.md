## 0.0.1

Initial release.

## 0.0.2

Update README and example.

## 0.0.3

Update README and example.

## 0.0.4

Global drawer

## 0.0.5

Update dependence

## 0.0.6

Update license

## 0.0.7

Update dependence

## 0.0.8

* Require Dart 3.6 / Flutter 3.27 or newer, and support the latest Flutter stable.
* Fix the position of dialogs opened from a widget inside a nested `Navigator` (for example a go_router `ShellRoute`) that does not start at the top left corner of the screen: the dialog is now aligned to the target widget instead of being shifted by the position of the nested navigator.
* `isGlobal` dialogs and `showGlobalDrawer` are now aligned inside the safe area. Before, they were shifted by the top/left safe area padding, which for example pushed bottom drawers partially off the screen and moved centered dialogs down on devices with a status bar or notch.
* `isGlobal` dialogs and `showGlobalDrawer` are now aligned to the whole screen (the navigator they are pushed onto) also when opened from a nested navigator, and stay aligned when the screen size changes (for example on rotation).
* `isGlobal` dialogs no longer need the `context` of a laid out box.
* Fix `CurvedAnimation`s of the default and drawer transitions not being disposed.
* Throw a descriptive error when `showAlignedDialog` is called with a `BuildContext` that is no longer valid.
* Add API documentation, tests and lints, and update the example.
