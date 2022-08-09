//Declare global variables

import 'package:my_greenhouse/services/greenhouse_service.dart';

class Environment {
  static String apiUrl = 'https://greenhouse.raoulh.pw/api';
  static String mfApiUrl = 'https://hub.myfood.eu/api/v1';

  static notifUrl(NotifType type) {
    var url = '${Environment.apiUrl}/notif';
    switch (type) {
      case NotifType.pH:
        url += "/ph";
        break;
      case NotifType.waterTemp:
        url += "/watertemp";
        break;
      case NotifType.airTemp:
        url += "/airtemp";
        break;
      case NotifType.humidity:
        url += "/humidity";
        break;
      default:
    }

    return url;
  }
}
