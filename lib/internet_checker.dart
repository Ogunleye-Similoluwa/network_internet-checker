import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

import 'src/probe.dart';

/// Whether the device can currently reach the internet.
enum InternetStatus {
  /// The device is on a network and can reach the internet.
  connected,

  /// The device is offline, or on a network that can't reach the internet.
  disconnected,
}

/// A host and port that [InternetChecker] tries to open a connection to.
class InternetCheckTarget {
  final String host;
  final int port;

  const InternetCheckTarget(this.host, [this.port = 443]);

  @override
  String toString() => '$host:$port';
}

/// A custom way to decide whether the internet is reachable, for example a
/// request to your own API.
typedef ReachabilityCheck = Future<bool> Function();

/// Watches whether the device can actually reach the internet, not just
/// whether it is on a network.
///
/// Network changes reported by connectivity_plus trigger a check right away,
/// and while anyone is listening it also re-checks every [checkInterval], so
/// it notices when a connected Wi-Fi network loses its internet access, and
/// when access comes back.
///
/// Most apps can use the shared [InternetChecker.instance].
class InternetChecker {
  /// Public DNS resolvers that accept TCP connections on port 53.
  static const defaultTargets = [
    InternetCheckTarget('1.1.1.1', 53),
    InternetCheckTarget('8.8.8.8', 53),
    InternetCheckTarget('208.67.222.222', 53),
  ];

  /// The shared checker used by the widgets when none is passed in.
  static final InternetChecker instance = InternetChecker();

  /// The hosts tried by the default check. Ignored when [reachabilityCheck]
  /// is set.
  final List<InternetCheckTarget> targets;

  /// How long to wait for each target before giving up on it.
  final Duration checkTimeout;

  /// How often to re-check while someone is listening. Set to null to only
  /// check when the network changes or [checkNow] is called.
  final Duration? checkInterval;

  /// Replaces the default socket check, for example with a request to your
  /// own server. On the web the default check trusts the browser's online
  /// signal, so pass one here if you need a stricter check there.
  final ReachabilityCheck? reachabilityCheck;

  InternetChecker({
    this.targets = defaultTargets,
    this.checkTimeout = const Duration(seconds: 3),
    this.checkInterval = const Duration(seconds: 10),
    this.reachabilityCheck,
  });

  final Connectivity _connectivity = Connectivity();
  late final StreamController<InternetStatus> _controller =
      StreamController<InternetStatus>.broadcast(
    onListen: _start,
    onCancel: _stop,
  );
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _timer;
  Future<InternetStatus>? _pendingCheck;
  InternetStatus? _lastStatus;
  int _generation = 0;

  /// The most recent result, or null if nothing has been checked yet.
  InternetStatus? get lastStatus => _lastStatus;

  /// Emits each time the status changes. Listening starts the background
  /// checks, and they stop once the last listener cancels.
  Stream<InternetStatus> get onStatusChange => _controller.stream;

  /// Checks right now whether the internet is reachable.
  Future<bool> get hasInternetAccess async =>
      await checkNow() == InternetStatus.connected;

  /// Checks right now and returns the result. Calls made while a check is
  /// already running share its result.
  Future<InternetStatus> checkNow() {
    final pending = _pendingCheck;
    if (pending != null) return pending;
    late final Future<InternetStatus> check;
    check = _check().whenComplete(() {
      if (identical(_pendingCheck, check)) _pendingCheck = null;
    });
    return _pendingCheck = check;
  }

  Future<InternetStatus> _check() async {
    final generation = _generation;
    var status = InternetStatus.connected;
    try {
      final network = await _connectivity.checkConnectivity();
      if (_isNone(network)) {
        status = InternetStatus.disconnected;
      }
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
    } on MissingPluginException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
    }
    if (status == InternetStatus.connected && !await _isReachable()) {
      status = InternetStatus.disconnected;
    }
    // A network change arrived while we were checking, so this result is
    // stale and the newer one wins.
    if (generation == _generation) _emit(status);
    return _lastStatus ?? status;
  }

  Future<bool> _isReachable() async {
    try {
      final check = reachabilityCheck;
      if (check != null) return await check();
      return await defaultReachabilityCheck(targets, checkTimeout);
    } catch (e) {
      developer.log('Reachability check failed', error: e);
      return false;
    }
  }

  void _onNetworkChanged(List<ConnectivityResult> result) {
    _generation++;
    if (_isNone(result)) {
      _emit(InternetStatus.disconnected);
    } else {
      // Run a fresh check even if one is in flight, since it started on the
      // old network.
      _pendingCheck = null;
      checkNow();
    }
  }

  void _emit(InternetStatus status) {
    if (status == _lastStatus) return;
    _lastStatus = status;
    if (_controller.hasListener) _controller.add(status);
  }

  void _start() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onNetworkChanged,
      onError: (Object e) =>
          developer.log('Connectivity stream error', error: e),
    );
    final interval = checkInterval;
    if (interval != null) {
      _timer = Timer.periodic(interval, (_) => checkNow());
    }
    checkNow();
  }

  void _stop() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _timer?.cancel();
    _timer = null;
  }

  static bool _isNone(List<ConnectivityResult> result) =>
      result.isEmpty || result.every((r) => r == ConnectivityResult.none);
}
