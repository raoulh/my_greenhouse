import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'package:my_greenhouse/models/graphs/graphs.dart';

Future<List<MeasValue>?> loadPHData() async {
  final String fileContent = await rootBundle.loadString('assets/ph_01.json');
  var jsonData = json.decode(fileContent);
  final RawData rawData = RawData.fromJson(jsonData);
  return rawData.data?.resultData;
}
