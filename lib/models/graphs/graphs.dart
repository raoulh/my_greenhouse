import 'package:my_greenhouse/models/json_conv.dart';

class RawData {
  final bool? failed;
  final bool? succeeded;
  final ResultData? data;

  RawData({this.data, this.failed, this.succeeded});

  factory RawData.fromJson(Map<String, dynamic> json) {
    return RawData(
      failed: json['failed'] as bool,
      succeeded: json['succeeded'] as bool,
      data: json['data'] != null ? ResultData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'succeeded': succeeded,
      'failed': failed,
      'data': data != null ? data?.toJson() : {},
    };
  }
}

class ResultData {
  final List<MeasValue> resultData;

  ResultData({required this.resultData});

  factory ResultData.fromJson(Map<String, dynamic> json) {
    final ResultData res = ResultData(resultData: []);
    if (json['resultData'] != null) {
      json['resultData'].forEach((v) {
        res.resultData.add(MeasValue.fromJson(v));
      });
    } else if (json['responceAirTemperatureData'] != null) {
      json['responceAirTemperatureData'].forEach((v) {
        res.resultData.add(MeasValue.fromJson(v));
      });
    } else if (json['resultHumidityMeasureData'] != null) {
      json['resultHumidityMeasureData'].forEach((v) {
        res.resultData.add(MeasValue.fromJson(v));
      });
    }

    return res;
  }

  Map<String, dynamic> toJson() {
    return {
      'resultData': resultData.map((v) => v.toJson()).toList(),
    };
  }
}

class MeasValue {
  final double value;
  final DateTime captureDate;

  MeasValue({required this.value, required this.captureDate});

  factory MeasValue.fromJson(Map<String, dynamic> json) {
    return MeasValue(
      value: JsonConv.toDouble(json['value']),
      captureDate: JsonConv.toDateTime(json['captureDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value.toString(),
      'captureDate': captureDate.toString(),
    };
  }
}
