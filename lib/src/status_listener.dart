import 'dart:async';

import 'package:flutter/widgets.dart';

import '../internet_checker.dart';

/// Keeps a widget's state in sync with an [InternetChecker].
mixin InternetStatusListener<T extends StatefulWidget> on State<T> {
  StreamSubscription<InternetStatus>? _subscription;
  InternetChecker? _subscribed;

  /// The checker this widget follows.
  InternetChecker get checker;

  /// The latest known status, or null before the first check finishes.
  InternetStatus? status;

  /// Called after [status] changes and the widget has been marked to rebuild.
  void onInternetStatusChanged(InternetStatus status) {}

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(checker, _subscribed)) {
      _subscription?.cancel();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribe() {
    final checker = this.checker;
    _subscribed = checker;
    status = checker.lastStatus;
    _subscription = checker.onStatusChange.listen(_update);
  }

  void _update(InternetStatus next) {
    if (!mounted || next == status) return;
    setState(() => status = next);
    onInternetStatusChanged(next);
  }

  /// Checks again right away and waits for the result.
  Future<void> recheck() async {
    _update(await checker.checkNow());
  }
}
