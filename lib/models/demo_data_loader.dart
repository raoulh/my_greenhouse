import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'package:my_greenhouse/models/graphs/graphs.dart';

/*
LastDay = 0,
LastWeek = 1
LastThreeMonths =2
*/

Future<List<MeasValue>?> loadPHDataDay() async {
  final String fileContent = await rootBundle.loadString('assets/ph_00.json');
  var jsonData = json.decode(fileContent);
  final RawData rawData = RawData.fromJson(jsonData);
  return rawData.data?.resultData;
}

Future<List<MeasValue>?> loadPHDataWeek() async {
  final String fileContent = await rootBundle.loadString('assets/ph_01.json');
  var jsonData = json.decode(fileContent);
  final RawData rawData = RawData.fromJson(jsonData);
  return rawData.data?.resultData;
}

Future<List<MeasValue>?> loadPHData3Months() async {
  final String fileContent = await rootBundle.loadString('assets/ph_02.json');
  var jsonData = json.decode(fileContent);
  final RawData rawData = RawData.fromJson(jsonData);
  return rawData.data?.resultData;
}
