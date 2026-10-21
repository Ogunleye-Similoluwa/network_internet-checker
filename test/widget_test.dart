import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_internet_checker/network_internet_checker.dart';

import 'test_utils.dart';

InternetChecker _checker({bool Function()? reachable}) => InternetChecker(
      checkInterval: const Duration(seconds: 10),
      reachabilityCheck: () async => reachable?.call() ?? true,
    );

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int count = 0;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () => setState(() => count++),
        child: Text('count $count'),
      );
}

void main() {
  group('ConnectivityWidget', () {
    testWidgets('works with only a child', (tester) async {
      FakeConnectivity(['none']).install(tester);
      await tester.pumpWidget(MaterialApp(
        home: ConnectivityWidget(
          checker: _checker(),
          child: const Text('Online content'),
        ),
      ));
      await settle(tester);

      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as AssetImage).keyName,
        'packages/network_internet_checker/assets/no_network.jpg',
      );
    });

    testWidgets('shows the child while online', (tester) async {
      FakeConnectivity(['wifi']).install(tester);
      await tester.pumpWidget(MaterialApp(
        home: ConnectivityWidget(
          checker: _checker(),
          child: const Text('Online content'),
        ),
      ));
      await settle(tester);

      expect(find.text('Online content'), findsOneWidget);
      expect(find.text('No internet connection'), findsNothing);
    });

    testWidgets('goes offline on Wi-Fi without internet, recovers alone',
        (tester) async {
      FakeConnectivity(['wifi']).install(tester);
      var reachable = false;
      final statuses = <InternetStatus>[];
      await tester.pumpWidget(MaterialApp(
        home: ConnectivityWidget(
          checker: _checker(reachable: () => reachable),
          onStatusChanged: statuses.add,
          child: const Text('Online content'),
        ),
      ));
      await settle(tester);
      expect(find.text('No internet connection'), findsOneWidget);

      reachable = true;
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(find.text('No internet connection'), findsNothing);
      expect(find.text('Online content'), findsOneWidget);
      expect(statuses, [InternetStatus.disconnected, InternetStatus.connected]);
    });

    testWidgets('follows network changes', (tester) async {
      final fake = FakeConnectivity(['wifi'])..install(tester);
      await tester.pumpWidget(MaterialApp(
        home: ConnectivityWidget(
          checker: _checker(),
          child: const Text('Online content'),
        ),
      ));
      await settle(tester);

      fake.emit(['none']);
      await settle(tester);
      expect(find.text('No internet connection'), findsOneWidget);

      fake.emit(['mobile']);
      await settle(tester);
      await tester.pumpAndSettle();
      expect(find.text('No internet connection'), findsNothing);
    });

    testWidgets('retry calls back, shows a spinner and recovers',
        (tester) async {
      final fake = FakeConnectivity(['none'])..install(tester);
      var presses = 0;
      await tester.pumpWidget(MaterialApp(
        home: ConnectivityWidget(
          checker: _checker(),
          onButtonPressed: () => presses++,
          child: const Text('Online content'),
        ),
      ));
      await settle(tester);

      fake.current = ['wifi'];
      await tester.tap(find.text('Try again'));
      await tester.pump();
      expect(presses, 1);

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text('No internet connection'), findsNothing);
      expect(find.text('Online content'), findsOneWidget);
    });

    testWidgets('spinner stays until the check finishes', (tester) async {
      FakeConnectivity(['none']).install(tester);
      await tester.pumpWidget(MaterialApp(
        home: ConnectivityWidget(
          checker: _checker(),
          child: const Text('Online content'),
        ),
      ));
      await settle(tester);

      await tester.tap(find.text('Try again'));
      await tester.pump();
      expect(find.byType(Loading), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.byType(Loading), findsNothing);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('offlineBuilder replaces the default screen', (tester) async {
      final fake = FakeConnectivity(['none'])..install(tester);
      await tester.pumpWidget(MaterialApp(
        home: ConnectivityWidget(
          checker: _checker(),
          offlineBuilder: (context, retry) => Center(
            child: ElevatedButton(
              onPressed: retry,
              child: const Text('Custom offline'),
            ),
          ),
          child: const Text('Online content'),
        ),
      ));
      await settle(tester);
      expect(find.text('Custom offline'), findsOneWidget);
      expect(find.byType(NoInternetScreen), findsNothing);

      fake.current = ['wifi'];
      await tester.tap(find.text('Custom offline'));
      await settle(tester);
      await tester.pumpAndSettle();
      expect(find.text('Custom offline'), findsNothing);
    });

    testWidgets('rebuildOnReconnect: false keeps the child state',
        (tester) async {
      final fake = FakeConnectivity(['wifi'])..install(tester);
      await tester.pumpWidget(MaterialApp(
        home: ConnectivityWidget(
          checker: _checker(),
          rebuildOnReconnect: false,
          child: const _Counter(),
        ),
      ));
      await settle(tester);
      await tester.tap(find.text('count 0'));
      await tester.pump();

      fake.emit(['none']);
      await settle(tester);
      fake.emit(['wifi']);
      await settle(tester);
      await tester.pumpAndSettle();
      expect(find.text('count 1'), findsOneWidget);
    });

    testWidgets('rebuildOnReconnect: true resets the child state',
        (tester) async {
      final fake = FakeConnectivity(['wifi'])..install(tester);
      await tester.pumpWidget(MaterialApp(
        home: ConnectivityWidget(
          checker: _checker(),
          child: const _Counter(),
        ),
      ));
      await settle(tester);
      await tester.tap(find.text('count 0'));
      await tester.pump();

      fake.emit(['none']);
      await settle(tester);
      fake.emit(['wifi']);
      await settle(tester);
      await tester.pumpAndSettle();
      expect(find.text('count 0'), findsOneWidget);
    });

    testWidgets('1.1.0 API still works', (tester) async {
      FakeConnectivity(['none']).install(tester);
      await tester.pumpWidget(MaterialApp(
        home: ConnectivityWidget(
          checker: _checker(),
          noInternetText: const Text('No internet'),
          textButton: const Text('Retry'),
          addIcon: true,
          icon: const Icon(Icons.wifi_off),
          onButtonPressed: null,
          child: const Text('Online content'),
        ),
      ));
      await settle(tester);

      expect(find.text('No internet'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('addIcon without an icon falls back to the image',
        (tester) async {
      FakeConnectivity(['none']).install(tester);
      await tester.pumpWidget(MaterialApp(
        home: ConnectivityWidget(
          checker: _checker(),
          addIcon: true,
          child: const Text('Online content'),
        ),
      ));
      await settle(tester);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('fits a small phone screen in dark mode', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      FakeConnectivity(['none']).install(tester);
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: ConnectivityWidget(
          checker: _checker(),
          description: const Text('Check your Wi-Fi or mobile data.'),
          child: const Text('Online content'),
        ),
      ));
      await settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('Try again').hitTestable(), findsOneWidget);
    });
  });

  group('OfflineBanner', () {
    testWidgets('keeps the child and shows offline, then back online',
        (tester) async {
      final fake = FakeConnectivity(['wifi'])..install(tester);
      await tester.pumpWidget(MaterialApp(
        home: OfflineBanner(
          checker: _checker(),
          child: const Text('Online content'),
        ),
      ));
      await settle(tester);
      expect(find.text('You\'re offline'), findsNothing);

      fake.emit(['none']);
      await settle(tester);
      await tester.pumpAndSettle();
      expect(find.text('You\'re offline'), findsOneWidget);
      expect(find.text('Online content'), findsOneWidget);

      fake.emit(['wifi']);
      await settle(tester);
      expect(find.text('Back online'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Back online'), findsNothing);
    });
  });

  group('InternetStatusBuilder', () {
    testWidgets('rebuilds with the status', (tester) async {
      final fake = FakeConnectivity(['wifi'])..install(tester);
      await tester.pumpWidget(MaterialApp(
        home: InternetStatusBuilder(
          checker: _checker(),
          builder: (context, status) => Text('status: ${status?.name}'),
        ),
      ));
      expect(find.text('status: null'), findsOneWidget);

      await settle(tester);
      expect(find.text('status: connected'), findsOneWidget);

      fake.emit(['none']);
      await settle(tester);
      expect(find.text('status: disconnected'), findsOneWidget);
    });
  });
}
