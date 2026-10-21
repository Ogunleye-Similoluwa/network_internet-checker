import 'dart:async';

import 'package:flutter/material.dart';

import 'internet_checker.dart';
import 'src/status_listener.dart';

/// Keeps [child] on screen and slides a slim "You're offline" bar in above it
/// while the internet is unreachable. When the connection comes back it
/// briefly shows "Back online" before hiding.
///
/// Wrap your whole app with it through `MaterialApp.builder`:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => OfflineBanner(child: child!),
/// )
/// ```
class OfflineBanner extends StatefulWidget {
  /// The content shown under the banner.
  final Widget child;

  /// The banner text while offline. Defaults to "You're offline".
  final Widget? offlineMessage;

  /// The banner text after reconnecting. Defaults to "Back online".
  final Widget? onlineMessage;

  /// How long the "back online" banner stays before hiding. Set to
  /// [Duration.zero] to hide it straight away.
  final Duration onlineMessageDuration;

  /// The banner colour while offline. Defaults to the theme's error colour.
  final Color? offlineColor;

  /// The banner colour after reconnecting. Defaults to a green.
  final Color? onlineColor;

  /// Called whenever the internet status changes.
  final ValueChanged<InternetStatus>? onStatusChanged;

  /// The checker to follow. Defaults to [InternetChecker.instance].
  final InternetChecker? checker;

  const OfflineBanner({
    super.key,
    required this.child,
    this.offlineMessage,
    this.onlineMessage,
    this.onlineMessageDuration = const Duration(seconds: 2),
    this.offlineColor,
    this.onlineColor,
    this.onStatusChanged,
    this.checker,
  });

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with InternetStatusListener {
  bool _showBackOnline = false;
  Timer? _hideTimer;

  @override
  InternetChecker get checker => widget.checker ?? InternetChecker.instance;

  @override
  void onInternetStatusChanged(InternetStatus status) {
    _hideTimer?.cancel();
    final reconnected = status == InternetStatus.connected &&
        widget.onlineMessageDuration > Duration.zero;
    _showBackOnline = reconnected;
    if (reconnected) {
      _hideTimer = Timer(widget.onlineMessageDuration, () {
        if (mounted) setState(() => _showBackOnline = false);
      });
    }
    widget.onStatusChanged?.call(status);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offline = status == InternetStatus.disconnected;
    final visible = offline || _showBackOnline;
    final colors = Theme.of(context).colorScheme;
    final background = offline
        ? widget.offlineColor ?? colors.error
        : widget.onlineColor ?? const Color(0xFF2E7D32);
    final foreground =
        ThemeData.estimateBrightnessForColor(background) == Brightness.dark
            ? Colors.white
            : Colors.black;

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: visible
              ? Material(
                  color: background,
                  child: SafeArea(
                    bottom: false,
                    child: Semantics(
                      liveRegion: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              offline
                                  ? Icons.wifi_off_rounded
                                  : Icons.wifi_rounded,
                              size: 16,
                              color: foreground,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: DefaultTextStyle.merge(
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: foreground),
                                child: offline
                                    ? widget.offlineMessage ??
                                        const Text('You\'re offline')
                                    : widget.onlineMessage ??
                                        const Text('Back online'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        Expanded(
          // The banner already covers the status bar, so the content below
          // shouldn't pad for it again.
          child: MediaQuery.removePadding(
            context: context,
            removeTop: visible,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

/// Rebuilds whenever the internet status changes.
///
/// `status` is null until the first check finishes.
///
/// ```dart
/// InternetStatusBuilder(
///   builder: (context, status) => Icon(
///     status == InternetStatus.disconnected ? Icons.cloud_off : Icons.cloud,
///   ),
/// )
/// ```
class InternetStatusBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, InternetStatus? status) builder;

  /// The checker to follow. Defaults to [InternetChecker.instance].
  final InternetChecker? checker;

  const InternetStatusBuilder({super.key, required this.builder, this.checker});

  @override
  State<InternetStatusBuilder> createState() => _InternetStatusBuilderState();
}

class _InternetStatusBuilderState extends State<InternetStatusBuilder>
    with InternetStatusListener {
  @override
  InternetChecker get checker => widget.checker ?? InternetChecker.instance;

  @override
  Widget build(BuildContext context) => widget.builder(context, status);
}
