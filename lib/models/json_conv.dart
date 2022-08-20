class JsonConv {
  static double toDouble(data) {
    if (data == null) {
      return 0;
    }
    if (data is int) {
      return data.toDouble();
    }
    return data as double;
  }

  static DateTime toDateTime(data) {
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

  static Duration toDuration(data) {
    if (data == null) {
      return const Duration();
    }

    double ns = toDouble(data) / 1000.0;
    return Duration(microseconds: ns.toInt());
  }

  static int fromDuration(Duration dur) {
    return dur.inMicroseconds * 1000;
  }
}
