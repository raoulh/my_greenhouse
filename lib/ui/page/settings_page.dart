import 'dart:io';

import 'package:flutter/material.dart';

import '../widgets/appbar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: "Settings",
        showSettings: false,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: Platform.isIOS
            ? const BouncingScrollPhysics()
            : const ClampingScrollPhysics(),
        child: Column(
          children: [
            Text("data"),
          ],
        ),
      ),
    );
  }
}
