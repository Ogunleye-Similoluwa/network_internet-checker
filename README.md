# network_internet_checker

[![pub package](https://img.shields.io/pub/v/network_internet_checker.svg)](https://pub.dev/packages/network_internet_checker)

Wrap any screen in `ConnectivityWidget` and it shows a "no internet" page
whenever the device goes offline, then brings your screen back, rebuilt from
scratch, as soon as the connection returns. It's built on
[connectivity_plus](https://pub.dev/packages/connectivity_plus) and works on
Android, iOS, web, macOS, Windows and Linux.

## Getting started

```bash
flutter pub add network_internet_checker
```

## Usage

```dart
import 'package:network_internet_checker/network_internet_checker.dart';

ConnectivityWidget(
  noInternetText: const Text('Check your internet and try again'),
  textButton: const Text('Try again'),
  addIcon: false,
  loadingColor: Colors.brown,
  onButtonPressed: () {
    // Optional: runs when the user taps the retry button.
  },
  child: const HomeScreen(),
)
```

### Parameters

| Parameter | Required | Description |
| --- | --- | --- |
| `child` | yes | The widget shown while the device is online. |
| `noInternetText` | yes | The message on the offline screen. |
| `textButton` | yes | The label of the retry button. |
| `addIcon` | yes | `true` to show your own `icon` instead of the bundled image. |
| `onButtonPressed` | yes (nullable) | Called when the retry button is tapped. Pass `null` if you don't need it. |
| `icon` | no | The widget shown on the offline screen when `addIcon` is `true`. |
| `loadingColor` | no | The colour of the retry spinner. Defaults to the theme's primary colour. |
| `backgroundColor` | no | The background of the offline screen. Defaults to white. |

### Good to know

- The widget reports whether the device is connected to a network (Wi-Fi,
  mobile, ethernet, VPN and so on). Like `connectivity_plus`, it can't tell
  whether that network actually reaches the internet, for example behind a
  captive portal.
- Tapping retry re-checks the connection immediately and shows a spinner for
  a few seconds.

A runnable app is in [`example/`](example/lib/main.dart).

## Contributing

Issues and pull requests are welcome on
[GitHub](https://github.com/Ogunleye-Similoluwa/network_internet-checker).

## Maintainer

Created and maintained by
[Similoluwa Ogunleye](https://www.linkedin.com/in/ogunleye-similoluwa-7b16a1250/).

## License

MIT, see [LICENSE](LICENSE).
