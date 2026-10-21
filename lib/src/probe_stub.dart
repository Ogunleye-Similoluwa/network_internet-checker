import '../internet_checker.dart';

/// Fallback used on platforms with neither `dart:io` nor the web.
Future<bool> defaultReachabilityCheck(
  List<InternetCheckTarget> targets,
  Duration timeout,
) async =>
    true;
