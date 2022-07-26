import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_greenhouse/services/auth_service.dart';
import 'package:provider/provider.dart';

import '../widgets/appbar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    Future.delayed(const Duration(milliseconds: 600), () {
      Navigator.pushReplacementNamed(context, 'login');
    });
  }

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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (Platform.isIOS)
                CupertinoButton.filled(
                  onPressed: () {
                    _logout(context);
                  },
                  child: const Text('Logout'),
                ),
              if (Platform.isAndroid)
                ElevatedButton(
                  //style: style,
                  onPressed: () {
                    _logout(context);
                  },
                  child: const Text('Logout'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
