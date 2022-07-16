import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_greenhouse/global/environment.dart';
import 'package:my_greenhouse/models/models.dart';

class AuthService with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool _authenticated = false;

  bool get authenticated => _authenticated;
  set authenticated(bool val) {
    _authenticated = val;
    notifyListeners();
  }

  static Future<String?> getToken() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
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
    final resp = await http.post(Uri.parse(url),
        body: jsonEncode(data), headers: {'Content-Type': 'application/json'});

    authenticated = false;

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      if (loginResponse.error) {
        return false;
      }
      await _saveToken(loginResponse.token);

      return true;
    } else {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    var tokenAuth = 'Bearer ';
    if (token != null) {
      tokenAuth += token;
    } else {
      return false;
    }

    final url = '${Environment.apiUrl}/auth/check';
    final resp = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Authentication': tokenAuth,
    });

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      if (loginResponse.error) {
        return false;
      }
      return true;
    } else {
      logout();
      return false;
    }
  }

  Future _saveToken(String token) async {
    return await _storage.write(key: 'token', value: token);
  }

  Future logout() async {
    await _storage.delete(key: 'token');
  }
}
