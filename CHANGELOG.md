# Changelog

## 1.2.0

- Added `package:network_internet_checker/network_internet_checker.dart` as the
  main import. `network_widget.dart` still works.
- Fixed the bundled no-network image not loading in apps that use the package.
- Fixed a crash when `onButtonPressed` is `null`, or when `addIcon` is `true`
  without an `icon` (the bundled image is shown instead).
- Fixed `setState() called after dispose()` when leaving the offline screen
  while a retry was in progress.
- The offline screen now scrolls and centres on small screens, and the image
  is capped at 280px so the retry button stays visible.
- The retry spinner now defaults to the theme's primary colour instead of
  white, which was invisible on the default white background.
- Supports `connectivity_plus` 6.x and 7.x.
- Removed the demo app from `lib/`; it now lives in `example/`.
- Added widget tests, API docs and package metadata.

## 1.1.0

- Published release.

## 1.0.0+2

- Updated Initial release of the `network_internet_checker` package.
- Updated the name of the package in the readme file.
- Updated Git repository for the code base.
- Formatted Loading Screen and Network Widget Screen.
