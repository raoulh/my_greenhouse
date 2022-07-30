import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_greenhouse/services/auth_service.dart';
import 'package:my_greenhouse/ui/widgets/appbar.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class NotifSettingsPage extends StatelessWidget {
  const NotifSettingsPage({Key? key}) : super(key: key);

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
        title: "Notification Settings",
        showSettings: false,
      ),
      backgroundColor: Colors.white,
      body: SettingsList(
        lightTheme: const SettingsThemeData(
          settingsListBackground: Colors.white,
          titleTextColor: Color(0xff2ea636),
        ),
        sections: [
          SettingsSection(
            title: const Text('Out of range'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: true,
                //leading: Icon(Icons.),
                title: const Text('Enable'),
              ),
              SettingsTile.navigation(
                title: const Text("Minimum value"),
                leading: const Icon(Icons.arrow_left_outlined),
                value: Text('6.3 pH'),
              ),
              SettingsTile.navigation(
                title: const Text("Maximum value"),
                leading: const Icon(Icons.arrow_right_outlined),
                value: Text('7.0 pH'),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Changes too quickly'),
            tiles: [
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: false,
                title: Text('Enable'),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('No updates for some time'),
            tiles: [
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: false,
                title: Text('Enable'),
              ),
              SettingsTile.navigation(
                title: const Text("Minimum value"),
                leading: const Icon(Icons.history_rounded),
                value: Text('2 hours'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
