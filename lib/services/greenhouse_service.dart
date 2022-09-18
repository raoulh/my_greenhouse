import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_greenhouse/global/environment.dart';
import 'package:my_greenhouse/models/demo_data_loader.dart';
import 'package:my_greenhouse/models/greenhouse_response.dart';
import 'package:my_greenhouse/models/prefs.dart';
import 'package:my_greenhouse/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class ProdUnitItem {
  final int prodId;
  final String name;
  final int index;
  final String prodRef;

  ProdUnitItem({
    required this.prodId,
    required this.name,
    required this.index,
    required this.prodRef,
  });
}

class GreenhouseService with ChangeNotifier {
  static const String _kCurrentProd = "current_prod_id";

  late final SharedPreferences _sharedPref;

  GreenhouseService() {
    initSharedPref();
  }

  void initSharedPref() async {
    _sharedPref = await SharedPreferences.getInstance();
  }

  int _currentProdUnitIndex = -1;
  int get currentProdUnitIndex {
    if (_currentProdUnitIndex >= 0) {
      return _currentProdUnitIndex;
    }

    var val = _sharedPref.getInt(_kCurrentProd);
    if (val == null) {
      _currentProdUnitIndex = 0;
      _sharedPref.setInt(_kCurrentProd, _currentProdUnitIndex);
    } else {
      _currentProdUnitIndex = val;
    }
    return _currentProdUnitIndex;
  }

  set currentProdUnitIndex(int current) {
    _currentProdUnitIndex = current;
    _sharedPref.setInt(_kCurrentProd, _currentProdUnitIndex);
    notifyListeners();
  }

  int _currentProdUnitId = -1;
  int get currentProdUnitId {
    if (_currentProdUnitIndex < prodUnits.length &&
        _currentProdUnitIndex >= 0) {
      _currentProdUnitId = prodUnits[_currentProdUnitIndex].prodId;
    }
    return _currentProdUnitId;
  }

  bool _hasMultiProdUnit = false;
  bool get hasMultiProdUnit => _hasMultiProdUnit;

  List<ProdUnitItem> prodUnits = [];

  Future<GreenhouseResponse> getCurrentData(bool notify) async {
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

      var data = greenhouseResponseFromJson(res.body);
      if (data.meas.length > 1) {
        _hasMultiProdUnit = true;
      } else {
        _hasMultiProdUnit = false;
      }

      prodUnits.clear();
      prodUnits = data.meas
          .asMap()
          .entries
          .map((e) => ProdUnitItem(
                prodId: e.value.productUnitId,
                name: e.value.productUnitType,
                index: e.key,
                prodRef: e.value.productUnitRef,
              ))
          .toList();

      if (notify) {
        notifyListeners();
      }

      return data;
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

      var data = greenhouseResponseFromJson(res.body);
      if (data.meas.length > 1) {
        _hasMultiProdUnit = true;
      } else {
        _hasMultiProdUnit = false;
      }
      notifyListeners();

      return data;
    } on SocketException {
      return throw Failure('Failure to connect to server');
    } on HttpException {
      return throw Failure("Unable to load data");
    } on FormatException {
      return throw Failure("Bad response format");
    }
  }

  Future<NotifSettingsResponse> getNotifSettings(NotifType type) async {
    final url = Environment.notifUrl(type, prodId: currentProdUnitId);
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
