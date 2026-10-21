import 'dart:async';
import 'dart:io';

import '../internet_checker.dart';

/// Opens a TCP connection to each target in parallel and returns true as soon
/// as any of them answers.
Future<bool> defaultReachabilityCheck(
  List<InternetCheckTarget> targets,
  Duration timeout,
) {
  if (targets.isEmpty) return Future.value(true);
  final result = Completer<bool>();
  var remaining = targets.length;
  for (final target in targets) {
    Socket.connect(target.host, target.port, timeout: timeout).then(
      (socket) {
        socket.destroy();
        if (!result.isCompleted) result.complete(true);
      },
      onError: (Object _) {
        remaining--;
        if (remaining == 0 && !result.isCompleted) result.complete(false);
      },
    );
  }
  return result.future;
}
