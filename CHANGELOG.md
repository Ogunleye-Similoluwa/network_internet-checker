# Changelog

## 1.2.0

**New**

- Detects real internet access, not just a network connection. Wi-Fi with no
  internet now counts as offline.
- Re-checks in the background, so the app recovers by itself when the
  connection returns.
- `InternetChecker`: status stream, `hasInternetAccess`, `checkNow()`, and
  configurable targets, timeout, interval or a fully custom check.
- `OfflineBanner`: keeps the app usable and shows an offline/back-online bar.
- `InternetStatusBuilder`: rebuild any widget from the current status.
- `ConnectivityWidget.offlineBuilder` for a fully custom offline page.
- `ConnectivityWidget.onStatusChanged`, `rebuildOnReconnect`, `description`,
  `checker` and `transitionDuration`.
- `NoInternetScreen`, the redesigned default offline page: theme-aware with
  dark mode, centred and scrollable on small screens, with a smooth fade.
- All `ConnectivityWidget` parameters except `child` are now optional.
- `package:network_internet_checker/network_internet_checker.dart` is the
  main import. `network_widget.dart` still works.

**Fixed**

- The bundled no-network image didn't load in apps that use the package.
- Crash when `onButtonPressed` was `null`, or `addIcon` was `true` without an
  `icon`.
- `setState() called after dispose()` when leaving the offline screen during
  a retry.
- The retry spinner was white on a white background. It now uses the theme's
  primary colour and stays until the check actually finishes.

**Other**

- Supports `connectivity_plus` 6.x and 7.x.
- `Screen2` is deprecated in favour of `NoInternetScreen`.
- The demo app moved from `lib/` to `example/`.
- Added tests, API docs, screenshots and package metadata.

## 1.1.0

- Published release.

## 1.0.0+2

- Updated Initial release of the `network_internet_checker` package.
- Updated the name of the package in the readme file.
- Updated Git repository for the code base.
- Formatted Loading Screen and Network Widget Screen.
