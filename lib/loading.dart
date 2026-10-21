import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// The spinner shown on the offline screen while a retry is in progress.
class Loading extends StatelessWidget {
  /// The spinner colour. Defaults to the theme's primary colour.
  final Color? loadingColor;

  const Loading({super.key, this.loadingColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitChasingDots(
        color: loadingColor ?? Theme.of(context).colorScheme.primary,
        size: 50,
      ),
    );
  }
}
