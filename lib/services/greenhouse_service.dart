import 'package:flutter/material.dart';
import 'package:my_greenhouse/global/environment.dart';
import 'package:my_greenhouse/models/greenhouse_response.dart';
import 'package:my_greenhouse/models/prefs.dart';
import 'package:my_greenhouse/services/auth_service.dart';
import 'package:http/http.dart' as http;

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

    final res = await http.get(Uri.parse(url), headers: {
      'Authorization': tokenAuth,
      'X-Device-Id': deviceId,
    });

    return greenhouseResponseFromJson(res.body);
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

    final res = await http.get(Uri.parse(url), headers: {
      'Authorization': tokenAuth,
      'X-Device-Id': deviceId,
    });

    return greenhouseResponseFromJson(res.body);
  }
}
