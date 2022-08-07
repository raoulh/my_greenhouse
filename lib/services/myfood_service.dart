import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_greenhouse/global/environment.dart';
import 'package:my_greenhouse/models/demo_data_loader.dart';
import 'package:my_greenhouse/models/graphs/graphs.dart';
import 'package:my_greenhouse/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:my_greenhouse/services/failure.dart';

class ChartResult {
  List<MeasValue> values;
  double zoomMin;
  double zoomMax;

  ChartResult(this.values, this.zoomMin, this.zoomMax);
}

class MyfoodService with ChangeNotifier {
  Future<List<MeasValue>?> _callApi(
      String dataType, int prodUnitId, int range) async {
    final url =
        '${Environment.mfApiUrl}/Measures/$dataType?id=$prodUnitId&range=$range';
    var tokenAuth = 'Bearer ';
    final token = await AuthService.getToken();

    if (token != null) {
      tokenAuth += token;
    } else {
      return [];
    }

    try {
      if (token == "demo_token") {
        var v = Random().nextInt(3);
        if (v == 1) {
          return await loadPHDataDay();
        } else if (v == 2) {
          return await loadPHDataWeek();
        } else {
          return await loadPHData3Months();
        }
      }

      final res = await http.get(Uri.parse(url), headers: {
        'Authorization': tokenAuth,
      });

      if (res.statusCode != 200) {
        throw Failure('Failure to connect to server');
      }

      return RawData.fromJson(json.decode(res.body)).data?.resultData;
    } on SocketException {
      throw Failure('Failure to connect to server');
    } on HttpException {
      throw Failure("Unable to load data");
    } on FormatException {
      throw Failure("Bad response format");
    }
  }

  Future<ChartResult> _callApiChart(String api, int prodUnitId) async {
    List<MeasValue>? data = await _callApi(api, prodUnitId, 0);

    data?.sort((a, b) {
      //sorting in ascending order
      return a.captureDate.compareTo(b.captureDate);
    });

    double zoomMin = 0;
    double zoomMax = 0;

    if (data!.isNotEmpty) {
      zoomMin = data.first.captureDate.millisecondsSinceEpoch.toDouble();
      zoomMax = data.last.captureDate.millisecondsSinceEpoch.toDouble();
    }

    //Load other ranges, and append them
    List<MeasValue>? dataW = await _callApi(api, prodUnitId, 1);
    List<MeasValue>? dataM = await _callApi(api, prodUnitId, 2);

    data = [...data, ...dataW!, ...dataM!];
    data.sort((a, b) {
      //sorting in ascending order
      return a.captureDate.compareTo(b.captureDate);
    });

    return ChartResult(data, zoomMin, zoomMax);
  }

  Future<ChartResult> getPHData(int prodUnitId) async {
    return _callApiChart("GetPHMeasureForUser", prodUnitId);
  }

  Future<ChartResult> getWaterTempData(int prodUnitId) async {
    return _callApiChart("GetWaterTemperatureForUser", prodUnitId);
  }

  Future<ChartResult> getAirTempData(int prodUnitId) async {
    return _callApiChart("GetAirTemperatureMeasureForUser", prodUnitId);
  }

  Future<ChartResult> getHumidityData(int prodUnitId) async {
    return _callApiChart("GetHumidityMeasureForUser", prodUnitId);
  }
}
