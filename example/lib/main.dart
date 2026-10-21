import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:network_internet_checker/network_internet_checker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'network_internet_checker example',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0x9f4376f8),
      ),
      home: Scaffold(
        body: ConnectivityWidget(
          noInternetText: const Text('Check your internet and try again'),
          addIcon: false,
          loadingColor: Colors.brown,
          textButton: const Text('Try Again'),
          onButtonPressed: () {
            if (kDebugMode) {
              print('Retrying connection');
            }
          },
          child: const Center(
            child: Text('Working', style: TextStyle(fontSize: 20)),
          ),
        ),
      ),
    );
  }
}
