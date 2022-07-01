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
      value: _toDouble(json['value']),
      captureDate: _toDateTime(json['captureDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value.toString(),
      'captureDate': captureDate.toString(),
    };
  }
}

double _toDouble(data) {
  if (data == null) {
    return 0;
  }
  if (data is int) {
    return data.toDouble();
  }
  return data as double;
}

DateTime _toDateTime(data) {
  if (data == null) {
    return DateTime.now();
  }
  if (data is String) {
    if (data.contains(".")) {
      //data = data.substring(0, data.length - 1);
    }

    return DateTime.parse(data);
  }
  return DateTime.now();
}
