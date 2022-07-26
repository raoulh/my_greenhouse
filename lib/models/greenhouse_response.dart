import 'dart:convert';

import 'package:my_greenhouse/models/json_conv.dart';

GreenhouseResponse greenhouseResponseFromJson(String str) =>
    GreenhouseResponse.fromJson(json.decode(str));

class GreenhouseResponse {
  GreenhouseResponse({
    required this.error,
    required this.username,
    required this.meas,
  });

  bool error;
  String username;
  final List<ProdUnit> meas;

  factory GreenhouseResponse.fromJson(Map<String, dynamic> json) {
    final GreenhouseResponse res = GreenhouseResponse(
      error: json["error"] ?? false,
      username: json["myfood_username"] ?? "",
      meas: [],
    );

    if (json['meas'] != null) {
      json['meas'].forEach((v) {
        res.meas.add(ProdUnit.fromJson(v));
      });
    }

    return res;
  }
}

class ProdUnit {
  ProdUnit({
    required this.productUnitId,
    required this.productUnitType,
    required this.ph,
    required this.waterTemp,
    required this.airTemp,
    required this.humidity,
  });

  int productUnitId;
  String productUnitType;
  ProdMeas ph;
  ProdMeas waterTemp;
  ProdMeas airTemp;
  ProdMeas humidity;

  factory ProdUnit.fromJson(Map<String, dynamic> json) {
    return ProdUnit(
      productUnitId: json["product_unit_id"],
      productUnitType: json["production_unit_type"],
      ph: ProdMeas.fromJson(json['ph']),
      waterTemp: ProdMeas.fromJson(json['watertemp']),
      airTemp: ProdMeas.fromJson(json['airtemp']),
      humidity: ProdMeas.fromJson(json['humidity']),
    );
  }
}

class ProdMeas {
  ProdMeas({
    required this.currentValue,
    required this.hourAverageValue,
    required this.dayAverageValue,
  });

  final double currentValue;
  final double hourAverageValue;
  final double dayAverageValue;

  factory ProdMeas.fromJson(Map<String, dynamic> json) => ProdMeas(
        currentValue: JsonConv.toDouble(json["current_value"]),
        hourAverageValue: JsonConv.toDouble(json["hour_average_value"]),
        dayAverageValue: JsonConv.toDouble(json["day_average_value"]),
      );
}
