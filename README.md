# network_internet_checker

[![pub package](https://img.shields.io/pub/v/network_internet_checker.svg)](https://pub.dev/packages/network_internet_checker)

Know when your users can **actually reach the internet**, not just whether
they're on Wi-Fi, and show them something better than a spinning loader when
they can't.

Wrap a screen in `ConnectivityWidget` and it swaps in an offline page while
the internet is unreachable, then brings your screen back by itself when the
connection returns.

<p>
  <img src="https://raw.githubusercontent.com/Ogunleye-Similoluwa/network_internet-checker/main/screenshots/offline_light.png" width="240" alt="Offline screen, light mode">
  <img src="https://raw.githubusercontent.com/Ogunleye-Similoluwa/network_internet-checker/main/screenshots/offline_dark.png" width="240" alt="Offline screen, dark mode">
  <img src="https://raw.githubusercontent.com/Ogunleye-Similoluwa/network_internet-checker/main/screenshots/banner.png" width="240" alt="Offline banner">
</p>

## Features

- **Real internet detection.** A Wi-Fi network with no internet (a router
  with no service, a café login page) counts as offline, unlike
  connectivity checks on their own.
- **Recovers automatically.** It keeps re-checking in the background, so the
  app comes back without the user tapping anything.
- **Three ways to show it:** a full-screen offline page, a slim banner that
  keeps your app usable, or your own UI through a builder.
- **Works out of the box:** one line of setup, light and dark mode, small
  screens, and smooth transitions.
- **Your own check:** point it at your API instead of the default probe.
- Android, iOS, web, macOS, Windows and Linux.

## Getting started

```bash
flutter pub add network_internet_checker
```

```dart
import 'package:network_internet_checker/network_internet_checker.dart';
```

**macOS only:** apps are sandboxed, so add this to both
`macos/Runner/DebugProfile.entitlements` and `Release.entitlements`:

```xml
<key>com.apple.security.network.client</key>
<true/>
```

## Usage

### Full-screen offline page

```dart
ConnectivityWidget(
  child: HomeScreen(),
)
```

Everything else is optional:

```dart
ConnectivityWidget(
  noInternetText: const Text('You\'re offline'),
  description: const Text('Check your Wi-Fi or mobile data and try again.'),
  textButton: const Text('Retry'),
  addIcon: true,
  icon: const Icon(Icons.wifi_off_rounded, size: 96),
  onButtonPressed: () => analytics.log('offline_retry'),
  onStatusChanged: (status) => debugPrint('Internet: $status'),
  rebuildOnReconnect: false, // keep form input and scroll position
  child: HomeScreen(),
)
```

### Your own offline UI

```dart
ConnectivityWidget(
  offlineBuilder: (context, retry) => MyOfflinePage(onRetry: retry),
  child: HomeScreen(),
)
```

`retry` checks again right away and completes when the check is done.

### Offline banner for the whole app

Keeps the app usable and slides a "You're offline" bar in at the top, then
shows "Back online" briefly when the connection returns.

```dart
MaterialApp(
  builder: (context, child) => OfflineBanner(child: child!),
  home: HomeScreen(),
)
```

### React to the status anywhere

```dart
InternetStatusBuilder(
  builder: (context, status) => Icon(
    status == InternetStatus.disconnected ? Icons.cloud_off : Icons.cloud_done,
  ),
)
```

Or without widgets:

```dart
final online = await InternetChecker.instance.hasInternetAccess;

InternetChecker.instance.onStatusChange.listen((status) {
  // InternetStatus.connected or InternetStatus.disconnected
});
```

## How it works

1. [connectivity_plus](https://pub.dev/packages/connectivity_plus) reports
   network changes. Losing the network is shown straight away.
2. When there is a network, the checker opens a short TCP connection to
   public DNS servers (Cloudflare, Google, OpenDNS) in parallel. If any of
   them answers within 3 seconds, the internet is reachable.
3. While a widget is listening, it re-checks every 10 seconds. Checks stop
   when nothing is listening.

On the web, browsers can't open raw connections, so it follows the browser's
online/offline signal unless you provide your own check.

### Customising the checker

```dart
final checker = InternetChecker(
  checkInterval: const Duration(seconds: 30), // null = only on network changes
  checkTimeout: const Duration(seconds: 5),
  targets: const [InternetCheckTarget('example.com', 443)],
  // Or replace the probe entirely, for example with your API's health check:
  reachabilityCheck: () async {
    final response = await http.head(Uri.parse('https://api.example.com/health'));
    return response.statusCode == 200;
  },
);

ConnectivityWidget(checker: checker, child: HomeScreen());
```

## API

| Widget / class | Use it for |
| --- | --- |
| `ConnectivityWidget` | Replace a screen with an offline page while offline. |
| `OfflineBanner` | Show a banner while offline and keep the app usable. |
| `InternetStatusBuilder` | Build any widget from the current status. |
| `NoInternetScreen` | The default offline page, to reuse in your own layouts. |
| `InternetChecker` | The status stream, one-off checks and configuration. |

### `ConnectivityWidget` parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `child` | required | Shown while online. |
| `noInternetText` | "No internet connection" | Heading on the offline page. |
| `description` | none | Supporting text under the heading. |
| `textButton` | "Try again" | Retry button label. |
| `addIcon` / `icon` | `false` / none | Show your own widget instead of the bundled image. |
| `loadingColor` | theme primary | Retry spinner colour. |
| `backgroundColor` | theme surface | Offline page background. |
| `onButtonPressed` | none | Called when retry is tapped. |
| `offlineBuilder` | none | Replace the offline page entirely. |
| `onStatusChanged` | none | Called on every status change. |
| `rebuildOnReconnect` | `true` | Rebuild `child` on reconnect, or keep its state. |
| `checker` | `InternetChecker.instance` | Use a custom checker. |
| `transitionDuration` | 300 ms | Fade between online and offline. |

## Upgrading from 1.1.0

Existing code keeps working. All parameters except `child` are now optional,
`package:network_internet_checker/network_widget.dart` still works as an
import, and `Screen2` is deprecated in favour of `NoInternetScreen`.

A runnable demo is in [`example/`](example/lib/main.dart).

## Contributing

Issues and pull requests are welcome on
[GitHub](https://github.com/Ogunleye-Similoluwa/network_internet-checker).

## Maintainer

Created and maintained by
[Similoluwa Ogunleye](https://www.linkedin.com/in/ogunleye-similoluwa-7b16a1250/).

## License

MIT, see [LICENSE](LICENSE).
