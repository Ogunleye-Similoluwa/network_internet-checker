import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'loading.dart';

/// Shows [child] while the device has a network connection, and a
/// "no internet" screen while it does not.
///
/// When the connection comes back, [child] is rebuilt from scratch so it can
/// reload anything that failed while offline.
class ConnectivityWidget extends StatefulWidget {
  /// The widget shown while the device is online.
  final Widget child;

  /// Called when the retry button on the offline screen is pressed.
  final void Function()? onButtonPressed;

  /// The message shown on the offline screen.
  final Text noInternetText;

  /// A custom widget shown on the offline screen when [addIcon] is true.
  final Widget? icon;

  /// Whether to show [icon] instead of the bundled no-network image.
  final bool addIcon;

  /// The label of the retry button.
  final Text textButton;

  /// The colour of the loading indicator shown while retrying.
  final Color? loadingColor;

  /// The background colour of the offline screen. Defaults to white.
  final Color? backgroundColor;

  const ConnectivityWidget({
    super.key,
    this.loadingColor,
    required this.child,
    required this.textButton,
    required this.noInternetText,
    required this.addIcon,
    this.icon,
    this.backgroundColor,
    required this.onButtonPressed,
  });

  @override
  State<ConnectivityWidget> createState() => _ConnectivityWidgetState();
}

class _ConnectivityWidgetState extends State<ConnectivityWidget> {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>>
      _connectivitySubscription;
  bool _isOffline = false;
  Key _childKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isOffline
        ? Screen2(
            onButtonPressed: widget.onButtonPressed,
            backgroundColor: widget.backgroundColor,
            noInternetText: widget.noInternetText,
            addIcon: widget.addIcon,
            icon: widget.icon,
            initConnectivity: initConnectivity,
            textButton: widget.textButton,
            loadingColor: widget.loadingColor,
          )
        : KeyedSubtree(
            key: _childKey,
            child: widget.child,
          );
  }

  /// Checks the current connectivity and updates the screen.
  Future<void> initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (!mounted) return;
    final isOffline =
        result.isEmpty || result.every((r) => r == ConnectivityResult.none);
    if (isOffline == _isOffline) return;
    setState(() {
      _isOffline = isOffline;
      // Rebuild the child from scratch when coming back online.
      if (!isOffline) _childKey = UniqueKey();
    });
  }
}

/// The screen shown by [ConnectivityWidget] while the device is offline.
class Screen2 extends StatefulWidget {
  final void Function()? onButtonPressed;
  final Future<void> Function() initConnectivity;
  final Text noInternetText;
  final Widget? icon;
  final bool addIcon;
  final Text textButton;
  final Color? loadingColor;
  final Color? backgroundColor;

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
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  bool _isLoading = false;
  Timer? _loadingTimer;

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  Future<void> _retry() async {
    widget.onButtonPressed?.call();
    setState(() => _isLoading = true);
    await widget.initConnectivity();
    if (!mounted) return;
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.addIcon ? widget.icon : null;
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon ??
                  Image.asset(
                    'assets/no_network.jpg',
                    package: 'network_internet_checker',
                    width: 280,
                  ),
              const SizedBox(height: 50),
              widget.noInternetText,
              const SizedBox(height: 30),
              _isLoading
                  ? Loading(loadingColor: widget.loadingColor)
                  : TextButton(
                      onPressed: _retry,
                      child: widget.textButton,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
