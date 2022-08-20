import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_greenhouse/global/environment.dart';
import 'package:my_greenhouse/models/demo_data_loader.dart';
import 'package:my_greenhouse/models/greenhouse_response.dart';
import 'package:my_greenhouse/models/prefs.dart';
import 'package:my_greenhouse/services/auth_service.dart';
import 'package:http/http.dart' as http;

import 'package:my_greenhouse/services/failure.dart';

enum NotifType {
  pH(1),
  waterTemp(2),
  airTemp(3),
  humidity(4);

  const NotifType(this.value);
  final int value;

  static NotifType getByValue(int i) {
    return NotifType.values.firstWhere((x) => x.value == i);
  }
}

class GreenhouseService with ChangeNotifier {
  Future<GreenhouseResponse> getCurrentData() async {
    final url = '${Environment.apiUrl}/data/full';
    var tokenAuth = 'Bearer ';
    final token = await AuthService.getToken();
    final deviceId = await AppPrefs.getDeviceId();

    if (token != null) {
      tokenAuth += token;
    } else {
      return GreenhouseResponse(error: true, username: "", meas: []);
    }

    try {
      if (token == "demo_token") {
        return await loadCurrent();
      }

      final res = await http.get(Uri.parse(url), headers: {
        'Authorization': tokenAuth,
        'X-Device-Id': deviceId,
      });

      if (res.statusCode != 200) {
        throw Failure('Failure to connect to server');
      }

      return greenhouseResponseFromJson(res.body);
    } on SocketException {
      throw Failure('Failure to connect to server');
    } on HttpException {
      throw Failure("Unable to load data");
    } on FormatException {
      throw Failure("Bad response format");
    }
  }

  Future<GreenhouseResponse> getRefreshedData() async {
    final url = '${Environment.apiUrl}/data/refresh';
    var tokenAuth = 'Bearer ';
    final token = await AuthService.getToken();
    final deviceId = await AppPrefs.getDeviceId();

    if (token != null) {
      tokenAuth += token;
    } else {
      return GreenhouseResponse(error: true, username: "", meas: []);
    }

    try {
      if (token == "demo_token") {
        await Future.delayed(const Duration(seconds: 2));
        return await loadCurrent();
      }

      final res = await http.get(Uri.parse(url), headers: {
        'Authorization': tokenAuth,
        'X-Device-Id': deviceId,
      });

      if (res.statusCode != 200) {
        return throw Failure('Failure to connect to server');
      }

      return greenhouseResponseFromJson(res.body);
    } on SocketException {
      return throw Failure('Failure to connect to server');
    } on HttpException {
      return throw Failure("Unable to load data");
    } on FormatException {
      return throw Failure("Bad response format");
    }
  }

  Future<NotifSettingsResponse> getNotifSettings(NotifType type) async {
    final url = Environment.notifUrl(type);
    var tokenAuth = 'Bearer ';
    final token = await AuthService.getToken();
    final deviceId = await AppPrefs.getDeviceId();

    if (token != null) {
      tokenAuth += token;
    } else {
      return NotifSettingsResponse.empty(type);
    }

    try {
      if (token == "demo_token") {
        await Future.delayed(const Duration(seconds: 2));
        return NotifSettingsResponse.empty(type);
      }

      final res = await http.get(Uri.parse(url), headers: {
        'Authorization': tokenAuth,
        'X-Device-Id': deviceId,
      });

      if (res.statusCode != 200) {
        return Future.error(Failure('Failure to connect to server'));
      }

      return notifSettingsResponseFromJson(res.body);
    } on SocketException {
      return Future.error(Failure('Failure to connect to server'));
    } on HttpException {
      return Future.error(Failure("Unable to load data"));
    } on FormatException {
      return Future.error(Failure("Bad response format"));
    }
  }

  Future<NotifSettingsResponse> setNotifSettings(
      NotifSettingsResponse notif) async {
    final url = Environment.notifUrl(notif.type);
    var tokenAuth = 'Bearer ';
    final token = await AuthService.getToken();
    final deviceId = await AppPrefs.getDeviceId();

    if (token != null) {
      tokenAuth += token;
    } else {
      return notif;
    }

    try {
      if (token == "demo_token") {
        await Future.delayed(const Duration(seconds: 2));
        return notif;
      }

      final res = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': tokenAuth,
          'X-Device-Id': deviceId,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(notif.toJson()),
      );

      if (res.statusCode != 200) {
        return Future.error(Failure('Failure to connect to server'));
      }

      return notif;
    } on SocketException {
      return Future.error(Failure('Failure to connect to server'));
    } on HttpException {
      return Future.error(Failure("Unable to load data"));
    } on FormatException {
      return Future.error(Failure("Bad response format"));
    }
  }
}
