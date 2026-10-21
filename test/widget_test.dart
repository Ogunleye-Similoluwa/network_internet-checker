import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_internet_checker/network_internet_checker.dart';

const _methodChannel = MethodChannel('dev.fluttercommunity.plus/connectivity');
const _eventChannel =
    EventChannel('dev.fluttercommunity.plus/connectivity_status');

/// Fakes the connectivity_plus platform channels.
class FakeConnectivity {
  FakeConnectivity(this.current);

  List<String> current;
  MockStreamHandlerEventSink? _sink;

  void install(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_methodChannel, (call) async {
      if (call.method == 'check') return current;
      return null;
    });
    messenger.setMockStreamHandler(
      _eventChannel,
      MockStreamHandler.inline(
        onListen: (_, sink) {
          _sink = sink;
        },
        onCancel: (_) {
          _sink = null;
        },
      ),
    );
    addTearDown(() {
      messenger.setMockMethodCallHandler(_methodChannel, null);
      messenger.setMockStreamHandler(_eventChannel, null);
    });
  }

  void emit(List<String> results) {
    current = results;
    _sink?.success(results);
  }
}

Widget _app({
  bool addIcon = false,
  Widget? icon,
  VoidCallback? onButtonPressed,
}) {
  return MaterialApp(
    home: ConnectivityWidget(
      noInternetText: const Text('No internet'),
      textButton: const Text('Retry'),
      addIcon: addIcon,
      icon: icon,
      onButtonPressed: onButtonPressed,
      child: const Text('Online content'),
    ),
  );
}

void main() {
  testWidgets('shows the child when online', (tester) async {
    FakeConnectivity(['wifi']).install(tester);
    await tester.pumpWidget(_app());
    await tester.pump();

    expect(find.text('Online content'), findsOneWidget);
    expect(find.text('No internet'), findsNothing);
  });

  testWidgets('shows the offline screen with the bundled image',
      (tester) async {
    FakeConnectivity(['none']).install(tester);
    await tester.pumpWidget(_app());
    await tester.pump();

    expect(find.text('No internet'), findsOneWidget);
    expect(find.text('Online content'), findsNothing);
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).keyName,
      'packages/network_internet_checker/assets/no_network.jpg',
    );
  });

  testWidgets('switches screens as connectivity changes', (tester) async {
    final fake = FakeConnectivity(['wifi'])..install(tester);
    await tester.pumpWidget(_app());
    await tester.pump();
    expect(find.text('Online content'), findsOneWidget);

    fake.emit(['none']);
    await tester.pump();
    await tester.pump();
    expect(find.text('No internet'), findsOneWidget);

    fake.emit(['mobile']);
    await tester.pump();
    await tester.pump();
    expect(find.text('Online content'), findsOneWidget);
  });

  testWidgets('uses the custom icon when addIcon is true', (tester) async {
    FakeConnectivity(['none']).install(tester);
    await tester.pumpWidget(
      _app(addIcon: true, icon: const Icon(Icons.wifi_off)),
    );
    await tester.pump();

    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('falls back to the bundled image when icon is missing',
      (tester) async {
    FakeConnectivity(['none']).install(tester);
    await tester.pumpWidget(_app(addIcon: true));
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('retry calls back, rechecks and recovers', (tester) async {
    final fake = FakeConnectivity(['none'])..install(tester);
    var presses = 0;
    await tester.pumpWidget(_app(onButtonPressed: () => presses++));
    await tester.pump();

    fake.current = ['wifi'];
    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(presses, 1);
    expect(find.text('Online content'), findsOneWidget);
  });

  testWidgets('retry works without an onButtonPressed callback',
      (tester) async {
    FakeConnectivity(['none']).install(tester);
    await tester.pumpWidget(_app());
    await tester.pump();

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(Loading), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Retry'), findsOneWidget);
  });
}
