import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:network_internet_checker/network_internet_checker.dart';

import 'test_utils.dart';

void main() {
  testWidgets('connected when on a network and the check passes',
      (tester) async {
    FakeConnectivity(['wifi']).install(tester);
    final checker = InternetChecker(reachabilityCheck: () async => true);

    expect(await checker.checkNow(), InternetStatus.connected);
    expect(checker.lastStatus, InternetStatus.connected);
  });

  testWidgets('disconnected on Wi-Fi without internet access', (tester) async {
    FakeConnectivity(['wifi']).install(tester);
    final checker = InternetChecker(reachabilityCheck: () async => false);

    expect(await checker.checkNow(), InternetStatus.disconnected);
  });

  testWidgets('skips the reachability check when there is no network',
      (tester) async {
    FakeConnectivity(['none']).install(tester);
    var probes = 0;
    final checker = InternetChecker(reachabilityCheck: () async {
      probes++;
      return true;
    });

    expect(await checker.checkNow(), InternetStatus.disconnected);
    expect(probes, 0);
  });

  testWidgets('treats a throwing check as disconnected', (tester) async {
    FakeConnectivity(['wifi']).install(tester);
    final checker =
        InternetChecker(reachabilityCheck: () async => throw Exception('x'));

    expect(await checker.checkNow(), InternetStatus.disconnected);
  });

  testWidgets('shares one check between concurrent callers', (tester) async {
    FakeConnectivity(['wifi']).install(tester);
    final gate = Completer<bool>();
    var probes = 0;
    final checker = InternetChecker(reachabilityCheck: () {
      probes++;
      return gate.future;
    });

    final a = checker.checkNow();
    final b = checker.checkNow();
    await tester.pump();
    gate.complete(true);

    expect(await a, InternetStatus.connected);
    expect(await b, InternetStatus.connected);
    expect(probes, 1);
  });

  testWidgets('re-checks periodically and emits only changes', (tester) async {
    final fake = FakeConnectivity(['wifi'])..install(tester);
    var reachable = true;
    final checker = InternetChecker(
      checkInterval: const Duration(seconds: 10),
      reachabilityCheck: () async => reachable,
    );
    final events = <InternetStatus>[];
    final sub = checker.onStatusChange.listen(events.add);
    await settle(tester);
    expect(events, [InternetStatus.connected]);

    // Same status again: no new event.
    await tester.pump(const Duration(seconds: 10));
    expect(events, [InternetStatus.connected]);

    // Internet drops while Wi-Fi stays up.
    reachable = false;
    await tester.pump(const Duration(seconds: 10));
    expect(events, [InternetStatus.connected, InternetStatus.disconnected]);

    // And comes back by itself.
    reachable = true;
    await tester.pump(const Duration(seconds: 10));
    expect(events.last, InternetStatus.connected);

    // Network loss is reported straight away, without waiting for a check.
    fake.emit(['none']);
    await settle(tester);
    expect(events.last, InternetStatus.disconnected);

    unawaited(sub.cancel());
    await tester.pump();
  });

  testWidgets('a network change overrides a check that was in flight',
      (tester) async {
    final fake = FakeConnectivity(['wifi'])..install(tester);
    final slow = Completer<bool>();
    final checker = InternetChecker(
      checkInterval: null,
      reachabilityCheck: () => slow.future,
    );
    final events = <InternetStatus>[];
    final sub = checker.onStatusChange.listen(events.add);
    await settle(tester);

    fake.emit(['none']);
    await settle(tester);
    slow.complete(true);
    await settle(tester);

    expect(events, [InternetStatus.disconnected]);
    unawaited(sub.cancel());
    await tester.pump();
  });
}
