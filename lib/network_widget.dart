import 'package:flutter/material.dart';

import 'internet_checker.dart';
import 'loading.dart';
import 'src/status_listener.dart';

export 'internet_checker.dart';

/// Builds a custom offline screen. Call [retry] to check the connection
/// again; it completes once the check has finished.
typedef OfflineWidgetBuilder = Widget Function(
  BuildContext context,
  Future<void> Function() retry,
);

/// Shows [child] while the device can reach the internet, and an offline
/// screen while it can't.
///
/// It checks real internet access, not just whether the device is on a
/// network, and keeps re-checking in the background, so the app recovers by
/// itself when the connection comes back.
///
/// ```dart
/// ConnectivityWidget(child: HomeScreen())
/// ```
class ConnectivityWidget extends StatefulWidget {
  /// The widget shown while the device is online.
  final Widget child;

  /// Called when the retry button on the default offline screen is pressed.
  final void Function()? onButtonPressed;

  /// The heading on the default offline screen. Defaults to
  /// "No internet connection".
  final Text? noInternetText;

  /// Supporting text under [noInternetText] on the default offline screen.
  final Widget? description;

  /// A custom widget shown on the default offline screen when [addIcon] is
  /// true.
  final Widget? icon;

  /// Whether to show [icon] instead of the bundled no-network image.
  final bool addIcon;

  /// The label of the retry button. Defaults to "Try again".
  final Text? textButton;

  /// The colour of the loading indicator shown while retrying.
  final Color? loadingColor;

  /// The background colour of the default offline screen. Defaults to the
  /// theme's surface colour.
  final Color? backgroundColor;

  /// Replaces the default offline screen entirely.
  final OfflineWidgetBuilder? offlineBuilder;

  /// Called whenever the internet status changes.
  final ValueChanged<InternetStatus>? onStatusChanged;

  /// Whether to rebuild [child] from scratch when the connection comes back,
  /// so it can reload anything that failed while offline. When false, [child]
  /// keeps its state (scroll position, form input and so on).
  final bool rebuildOnReconnect;

  /// The checker to follow. Defaults to [InternetChecker.instance].
  final InternetChecker? checker;

  /// How long the switch between [child] and the offline screen takes.
  final Duration transitionDuration;

  const ConnectivityWidget({
    super.key,
    required this.child,
    this.textButton,
    this.noInternetText,
    this.description,
    this.addIcon = false,
    this.icon,
    this.loadingColor,
    this.backgroundColor,
    this.onButtonPressed,
    this.offlineBuilder,
    this.onStatusChanged,
    this.rebuildOnReconnect = true,
    this.checker,
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  @override
  State<ConnectivityWidget> createState() => _ConnectivityWidgetState();
}

class _ConnectivityWidgetState extends State<ConnectivityWidget>
    with InternetStatusListener {
  Key _childKey = UniqueKey();

  @override
  InternetChecker get checker => widget.checker ?? InternetChecker.instance;

  @override
  void onInternetStatusChanged(InternetStatus status) {
    if (status == InternetStatus.connected && widget.rebuildOnReconnect) {
      _childKey = UniqueKey();
    }
    widget.onStatusChanged?.call(status);
  }

  @override
  Widget build(BuildContext context) {
    // Until the first check finishes, assume we're online so the app doesn't
    // flash the offline screen on launch.
    final offline = status == InternetStatus.disconnected;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Visibility(
          visible: !offline,
          maintainState: true,
          maintainAnimation: true,
          maintainSize: true,
          child: KeyedSubtree(key: _childKey, child: widget.child),
        ),
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: widget.transitionDuration,
            child: offline ? _buildOffline(context) : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildOffline(BuildContext context) {
    final builder = widget.offlineBuilder;
    if (builder != null) {
      return KeyedSubtree(
        key: const ValueKey('offline'),
        child: Builder(builder: (context) => builder(context, recheck)),
      );
    }
    return NoInternetScreen(
      key: const ValueKey('offline'),
      onRetry: recheck,
      onButtonPressed: widget.onButtonPressed,
      noInternetText: widget.noInternetText,
      description: widget.description,
      textButton: widget.textButton,
      icon: widget.addIcon ? widget.icon : null,
      loadingColor: widget.loadingColor,
      backgroundColor: widget.backgroundColor,
    );
  }
}

/// The default offline screen shown by [ConnectivityWidget].
///
/// You can also use it inside your own [ConnectivityWidget.offlineBuilder].
class NoInternetScreen extends StatefulWidget {
  /// Checks the connection again. The spinner shows until it completes.
  final Future<void> Function() onRetry;

  /// Called when the retry button is pressed, before [onRetry].
  final void Function()? onButtonPressed;

  /// The heading. Defaults to "No internet connection".
  final Text? noInternetText;

  /// Supporting text under the heading.
  final Widget? description;

  /// The label of the retry button. Defaults to "Try again".
  final Text? textButton;

  /// Shown instead of the bundled no-network image.
  final Widget? icon;

  /// The colour of the retry spinner. Defaults to the theme's primary colour.
  final Color? loadingColor;

  /// The background colour. Defaults to the theme's surface colour.
  final Color? backgroundColor;

  const NoInternetScreen({
    super.key,
    required this.onRetry,
    this.onButtonPressed,
    this.noInternetText,
    this.description,
    this.textButton,
    this.icon,
    this.loadingColor,
    this.backgroundColor,
  });

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isRetrying = false;

  Future<void> _retry() async {
    widget.onButtonPressed?.call();
    setState(() => _isRetrying = true);
    // Keep the spinner up briefly even when the check is instant, so the tap
    // visibly did something.
    await Future.wait([
      widget.onRetry(),
      Future<void>.delayed(const Duration(milliseconds: 600)),
    ]);
    if (mounted) setState(() => _isRetrying = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? colors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.icon ??
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/no_network.jpg',
                          package: 'network_internet_checker',
                          width: 220,
                        ),
                      ),
                  const SizedBox(height: 32),
                  DefaultTextStyle.merge(
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: colors.onSurface),
                    child: widget.noInternetText ??
                        const Text('No internet connection'),
                  ),
                  if (widget.description != null) ...[
                    const SizedBox(height: 8),
                    DefaultTextStyle.merge(
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colors.onSurfaceVariant),
                      child: widget.description!,
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 56,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isRetrying
                          ? Loading(loadingColor: widget.loadingColor)
                          : FilledButton.tonalIcon(
                              onPressed: _retry,
                              icon: const Icon(Icons.refresh_rounded),
                              label:
                                  widget.textButton ?? const Text('Try again'),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The offline screen from version 1.1.0.
@Deprecated('Use NoInternetScreen instead. Will be removed in 2.0.0.')
class Screen2 extends StatelessWidget {
  final void Function()? onButtonPressed;
  final Future<void> Function() initConnectivity;
  final Text noInternetText;
  final Widget? icon;
  final bool addIcon;
  final Text textButton;
  final Color? loadingColor;
  final Color? backgroundColor;

  @Deprecated('Use NoInternetScreen instead. Will be removed in 2.0.0.')
  const Screen2({
    super.key,
    required this.onButtonPressed,
    required this.textButton,
    required this.noInternetText,
    required this.addIcon,
    this.backgroundColor,
    required this.initConnectivity,
    this.icon,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    return NoInternetScreen(
      onRetry: initConnectivity,
      onButtonPressed: onButtonPressed,
      noInternetText: noInternetText,
      textButton: textButton,
      icon: addIcon ? icon : null,
      loadingColor: loadingColor,
      backgroundColor: backgroundColor,
    );
  }
}
