import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_greenhouse/global/environment.dart';
import 'package:my_greenhouse/models/greenhouse_response.dart';
import 'package:my_greenhouse/models/prefs.dart';
import 'package:my_greenhouse/services/auth_service.dart';
import 'package:http/http.dart' as http;

import 'package:my_greenhouse/services/failure.dart';

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
      final res = await http.get(Uri.parse(url), headers: {
        'Authorization': tokenAuth,
        'X-Device-Id': deviceId,
      });

      return greenhouseResponseFromJson(res.body);
    } on SocketException {
      throw Failure('Failure to connect to server');
    } on HttpException {
      throw Failure("Unable to load data");
    } on FormatException {
      throw Failure("Bad response format");
    }
  }
}
