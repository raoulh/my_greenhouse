import 'package:flutter/material.dart';

class NoRoutePage extends StatelessWidget {
  const NoRoutePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("This shouldn't happen :("),
      ),
    );
  }
}
