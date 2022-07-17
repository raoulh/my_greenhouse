import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_greenhouse/global/environment.dart';
import 'package:my_greenhouse/models/graphs/graphs.dart';
import 'package:my_greenhouse/services/auth_service.dart';
import 'package:http/http.dart' as http;

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

    final res = await http.get(Uri.parse(url), headers: {
      'Authorization': tokenAuth,
    });

    return RawData.fromJson(json.decode(res.body)).data?.resultData;
  }

  Future<ChartResult> _callApiChart(String api, int prodUnitId) async {
    List<MeasValue>? data = await _callApi(api, prodUnitId, 0);

    data?.sort((a, b) {
      //sorting in ascending order
      return a.captureDate.compareTo(b.captureDate);
    });

    double zoomMin = data!.first.captureDate.millisecondsSinceEpoch.toDouble();
    double zoomMax = data.last.captureDate.millisecondsSinceEpoch.toDouble();

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
