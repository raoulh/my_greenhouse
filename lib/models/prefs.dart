import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_ids/unique_ids.dart';

class AppPrefs {
  static const String _kDeviceId = "device_id";

  static Future<String> getDeviceId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var devid = prefs.getString(_kDeviceId);
    if (devid == null) {
      try {
        devid = await UniqueIds.uuid;
        prefs.setString(_kDeviceId, devid!);
      } on PlatformException {
        // ignore: avoid_print
        print("Failed to create UUID");
      }
    }

    return devid ?? '';
  }
}
