import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    Connectivity conn = Connectivity();

    conn.onConnectivityChanged.listen((event) async {
      if (event == ConnectivityResult.none) {
        _isOnline = false;
        notifyListeners();
      } else {
        _isOnline = true;
        notifyListeners();
      }
    });
  }
}
