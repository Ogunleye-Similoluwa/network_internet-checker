import '../internet_checker.dart';

/// Browsers can't open raw sockets, and cross-origin requests are blocked by
/// CORS, so on the web we rely on the browser's own online/offline signal
/// (reported through connectivity_plus).
Future<bool> defaultReachabilityCheck(
  List<InternetCheckTarget> targets,
  Duration timeout,
) async =>
    true;
