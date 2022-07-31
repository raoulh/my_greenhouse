import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_greenhouse/ui/widgets/appbar.dart';
import 'package:settings_ui/settings_ui.dart';

class NotifSettingsPage extends StatelessWidget {
  const NotifSettingsPage({Key? key}) : super(key: key);

  void _showHelpDialog(context, String text) {
    if (!Platform.isIOS) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: const Text("Help"),
            content: Text(text),
            actions: <Widget>[
              TextButton(
                child: const Text("Close"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Help"),
          content: Text(text),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
    }
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
        //platform: DevicePlatform.android,
        lightTheme: SettingsThemeData(
          settingsListBackground: Platform.isAndroid ? Colors.white : null,
          titleTextColor: const Color(0xff2ea636),
        ),
        sections: [
          SettingsSection(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Out of range'.toUpperCase()),
                CupertinoButton(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    CupertinoIcons.info,
                    color: Colors.grey[700],
                    size: 25.0,
                  ),
                  onPressed: () => _showHelpDialog(context,
                      "When this option is enabled, a notification will be sent when the value goes out of range"),
                ),
              ],
            ),
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Changes too quickly'.toUpperCase()),
                CupertinoButton(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    CupertinoIcons.info,
                    color: Colors.grey[700],
                    size: 25.0,
                  ),
                  onPressed: () => _showHelpDialog(context,
                      "When this option is enabled, a notification will be sent when the value changes too quickly in a small amount of time"),
                ),
              ],
            ),
            tiles: [
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: false,
                title: const Text('Enable'),
              ),
            ],
          ),
          SettingsSection(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('No updates for some time'.toUpperCase()),
                CupertinoButton(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    CupertinoIcons.info,
                    color: Colors.grey[700],
                    size: 25.0,
                  ),
                  onPressed: () => _showHelpDialog(context,
                      "When this option is enabled, a notification will be sent when no data are available for more than the selected time"),
                ),
              ],
            ),
            tiles: [
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: false,
                title: const Text('Enable'),
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
