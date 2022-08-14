import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_greenhouse/global/environment.dart';
import 'package:my_greenhouse/models/models.dart';
import 'package:my_greenhouse/services/failure.dart';
import 'package:push/push.dart';

class AuthService with ChangeNotifier {
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock,
      accountName: "greenhouse_storage",
    ),
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  bool _authenticated = false;

  bool get authenticated => _authenticated;
  set authenticated(bool val) {
    _authenticated = val;
    notifyListeners();
  }

  String _pushToken = "";
  late StreamSubscription<String> _newTokenSub;

  AuthService() {
    requestNotificationPermissions();

    Push.instance.token.then((value) {
      print("Initial Push token: $value");
      _pushToken = value ?? "";
    });

    _newTokenSub = Push.instance.onNewToken.listen((value) {
      print("Push token: $value");
      _pushToken = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _newTokenSub.cancel();
  }

  void requestNotificationPermissions() async {
    await Push.instance.requestPermission();
  }

  Future<void> sendPushToken() async {
    final url = '${Environment.apiUrl}/notif/id';
    var tokenAuth = 'Bearer ';
    final token = await AuthService.getToken();
    final deviceId = await AppPrefs.getDeviceId();

    if (token != null) {
      tokenAuth += token;
    } else {
      return;
    }

    try {
      if (token == "demo_token") {
        return;
      }

      if (_pushToken == "") {
        return;
      }

      final data = {
        'token': _pushToken,
        'hw': Platform.isAndroid
            ? 2
            : Platform.isIOS
                ? 1
                : 0
      };

      final res = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': tokenAuth,
          'X-Device-Id': deviceId,
        },
        body: jsonEncode(data),
      );

      if (res.statusCode != 200) {
        print('Failure to connect to server');
      }
    } on SocketException {
      print("sendPushToken failed");
    } on HttpException {
      print("sendPushToken failed");
    } on FormatException {
      print("sendPushToken failed");
    }
  }

  static Future<String?> getToken() async {
    final token = await _storage.read(key: 'token');
    return token;
  }

  static Future<void> deleteToken() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'token');
  }

  Future<bool> login(String email, String password) async {
    authenticated = true;
    final deviceId = await AppPrefs.getDeviceId();
    final data = {'username': email, 'pass': password, 'device_id': deviceId};
    final url = '${Environment.apiUrl}/auth/login';

    try {
      if (email == "demo" && password == "demo") {
        //enable demo mode
        await _saveToken("demo_token");
        return true;
      }

      final resp = await http.post(Uri.parse(url),
          body: jsonEncode(data),
          headers: {'Content-Type': 'application/json'});

      authenticated = false;

      if (resp.statusCode == 200) {
        final loginResponse = loginResponseFromJson(resp.body);
        if (loginResponse.error) {
          return false;
        }
        await _saveToken(loginResponse.token);

        sendPushToken();

        return true;
      } else {
        return false;
      }
    } on SocketException {
      throw Failure('Failure to connect to server');
    } on HttpException {
      throw Failure("Unable to load data");
    } on FormatException {
      throw Failure("Bad response format");
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _getToken();

    if (token == "demo_token") {
      return true;
    }

    var tokenAuth = 'Bearer ';
    if (token != null) {
      tokenAuth += token;
    } else {
      return false;
    }
    final deviceId = await AppPrefs.getDeviceId();

    final url = '${Environment.apiUrl}/auth/check';
    final resp = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authorization': tokenAuth,
      'X-Device-Id': deviceId,
    });

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      if (loginResponse.error) {
        return false;
      }
      sendPushToken();
      return true;
    } else {
      logout();
      return false;
    }
  }

  Future<String?> _getToken() async {
    final token = await _storage.read(key: 'token');
    debugPrint("reading token: $token");
    return token;
  }

  Future _saveToken(String token) async {
    debugPrint("saving token: $token");
    return await _storage.write(key: 'token', value: token);
  }

  Future logout() async {
    await _storage.delete(key: 'token');
  }
}
