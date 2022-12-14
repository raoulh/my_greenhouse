import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:my_greenhouse/models/json_conv.dart';
import 'package:my_greenhouse/services/greenhouse_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    required this.productUnitRef,
    required this.ph,
    required this.waterTemp,
    required this.airTemp,
    required this.humidity,
  });

  int productUnitId;
  String productUnitType;
  String productUnitRef;
  ProdMeas ph;
  ProdMeas waterTemp;
  ProdMeas airTemp;
  ProdMeas humidity;

  factory ProdUnit.fromJson(Map<String, dynamic> json) {
    return ProdUnit(
      productUnitId: json["product_unit_id"],
      productUnitType: json["production_unit_type"],
      productUnitRef: json["production_unit_ref"] ?? "",
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
    required this.currentTime,
  });

  final double currentValue;
  final double hourAverageValue;
  final double dayAverageValue;
  final DateTime currentTime;

  factory ProdMeas.empty() => ProdMeas(
        currentValue: 0,
        hourAverageValue: 0,
        dayAverageValue: 0,
        currentTime: DateTime(0),
      );

  factory ProdMeas.fromJson(Map<String, dynamic> json) => ProdMeas(
        currentValue: JsonConv.toDouble(json["current_value"]),
        hourAverageValue: JsonConv.toDouble(json["hour_average_value"]),
        dayAverageValue: JsonConv.toDouble(json["day_average_value"]),
        currentTime: JsonConv.toDateTime(json['current_time']),
      );
}

NotifSettingsResponse notifSettingsResponseFromJson(String str) =>
    NotifSettingsResponse.fromJson(json.decode(str));

class NotifSettingsResponse {
  NotifSettingsResponse({
    required this.type,
    required this.rangeEnabled,
    required this.rangeMin,
    required this.rangeMax,
    required this.tooFastEnabled,
    required this.timeEnabled,
    required this.timeMin,
    required this.prodId,
  });

  final NotifType type;
  bool rangeEnabled;
  double rangeMin;
  double rangeMax;
  bool tooFastEnabled;
  bool timeEnabled;
  Duration timeMin;
  int prodId;

  String getUnit() {
    if (type == NotifType.pH) {
      return "pH";
    } else if (type == NotifType.humidity) {
      return "%";
    } else {
      return "??";
    }
  }

  String getFormatedTimeMin(BuildContext context) {
    return AppLocalizations.of(context).unitHours(timeMin.inHours);
  }

  factory NotifSettingsResponse.empty(NotifType t) => NotifSettingsResponse(
        type: t,
        rangeEnabled: false,
        rangeMin: 0,
        rangeMax: 0,
        tooFastEnabled: false,
        timeEnabled: false,
        timeMin: const Duration(),
        prodId: 0,
      );

  factory NotifSettingsResponse.fromJson(Map<String, dynamic> json) =>
      NotifSettingsResponse(
        type: NotifType.getByValue(json["type"]),
        rangeEnabled: json["range_enabled"],
        rangeMin: JsonConv.toDouble(json["range_min"]),
        rangeMax: JsonConv.toDouble(json["range_max"]),
        tooFastEnabled: json["too_fast_enabled"],
        timeEnabled: json["time_enabled"],
        timeMin: JsonConv.toDuration(json["time_min"]),
        prodId: json["product_unit_id"],
      );

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'range_enabled': rangeEnabled,
      'range_min': rangeMin,
      'range_max': rangeMax,
      'too_fast_enabled': tooFastEnabled,
      'time_enabled': timeEnabled,
      'time_min': JsonConv.fromDuration(timeMin),
      'product_unit_id': prodId,
    };
  }
}
