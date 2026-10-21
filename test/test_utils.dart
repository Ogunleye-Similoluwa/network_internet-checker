import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _methodChannel = MethodChannel('dev.fluttercommunity.plus/connectivity');
const _eventChannel =
    EventChannel('dev.fluttercommunity.plus/connectivity_status');

/// Fakes the connectivity_plus platform channels.
class FakeConnectivity {
  FakeConnectivity(this.current);

  /// What `checkConnectivity` returns, e.g. `['wifi']` or `['none']`.
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

  /// Simulates the OS reporting a network change.
  void emit(List<String> results) {
    current = results;
    _sink?.success(results);
  }
}

/// Lets platform messages and microtasks settle, then rebuilds.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}
