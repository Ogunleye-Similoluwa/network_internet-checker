import 'package:flutter/material.dart';
import 'package:network_internet_checker/network_internet_checker.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'network_internet_checker',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF4376F8)),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF4376F8),
        brightness: Brightness.dark,
      ),
      home: const DemoPicker(),
    );
  }
}

class DemoPicker extends StatelessWidget {
  const DemoPicker({super.key});

  @override
  Widget build(BuildContext context) {
    void open(Widget page) => Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => page));

    return Scaffold(
      appBar: AppBar(
        title: const Text('network_internet_checker'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InternetStatusBuilder(
              builder: (context, status) => Icon(
                switch (status) {
                  InternetStatus.connected => Icons.cloud_done_rounded,
                  InternetStatus.disconnected => Icons.cloud_off_rounded,
                  null => Icons.cloud_queue_rounded,
                },
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Turn on airplane mode, or join a Wi-Fi network with no '
              'internet, to see each one react.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.fullscreen_rounded),
            title: const Text('Full-screen offline page'),
            subtitle: const Text('ConnectivityWidget'),
            onTap: () => open(const FullScreenDemo()),
          ),
          ListTile(
            leading: const Icon(Icons.brush_rounded),
            title: const Text('Custom offline page'),
            subtitle: const Text('ConnectivityWidget.offlineBuilder'),
            onTap: () => open(const CustomDemo()),
          ),
          ListTile(
            leading: const Icon(Icons.view_day_rounded),
            title: const Text('Offline banner'),
            subtitle: const Text('OfflineBanner'),
            onTap: () => open(const BannerDemo()),
          ),
        ],
      ),
    );
  }
}

class FullScreenDemo extends StatelessWidget {
  const FullScreenDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Full-screen')),
      body: const ConnectivityWidget(
        description: Text('Check your Wi-Fi or mobile data and try again.'),
        child: Center(
            child: Text('You\'re online', style: TextStyle(fontSize: 20))),
      ),
    );
  }
}

class CustomDemo extends StatelessWidget {
  const CustomDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom')),
      body: ConnectivityWidget(
        offlineBuilder: (context, retry) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.signal_wifi_bad_rounded, size: 72),
              const SizedBox(height: 16),
              const Text('Lost the signal'),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: retry, child: const Text('Reconnect')),
            ],
          ),
        ),
        child: const Center(
            child: Text('You\'re online', style: TextStyle(fontSize: 20))),
      ),
    );
  }
}

class BannerDemo extends StatelessWidget {
  const BannerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return OfflineBanner(
      child: Scaffold(
        appBar: AppBar(title: const Text('Banner')),
        body: ListView.builder(
          itemCount: 30,
          itemBuilder: (context, i) =>
              ListTile(title: Text('Cached item ${i + 1}')),
        ),
      ),
    );
  }
}
