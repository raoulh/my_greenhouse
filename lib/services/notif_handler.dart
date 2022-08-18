import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_greenhouse/main.dart';
import 'package:my_greenhouse/ui/widgets/error_dialog.dart';
import 'package:push/push.dart';

class NotifHandler with ChangeNotifier {
  late StreamSubscription<Map<String?, Object?>> _notifTapSub;
  late StreamSubscription<RemoteMessage> _notifMessageSub;
  late StreamSubscription<RemoteMessage> _notifBackgroundSub;

  NotifHandler() {
    Push.instance.notificationTapWhichLaunchedAppFromTerminated
        .then((remoteMessage) {
      if (remoteMessage == null) {
        print("App was not launched by tapping a notification");
      } else {
        print('Notification tap launched app from terminated state:\n'
            'RemoteMessage: $remoteMessage \n');
      }
      //notificationWhichLaunchedApp.value = data;
    });

    _notifTapSub = Push.instance.onNotificationTap.listen((data) {
      print('Notification was tapped:\n'
          'Data: $data \n');
      //tappedNotificationPayloads.value += [data];
    });

    _notifMessageSub = Push.instance.onMessage.listen((message) {
      print('RemoteMessage received while app is in foreground:\n'
          'RemoteMessage.Notification: ${message.notification} \n'
          ' title: ${message.notification?.title.toString()}\n'
          ' body: ${message.notification?.body.toString()}\n'
          'RemoteMessage.Data: ${message.data}');
      if (navigatorKey.currentContext != null) {
        final String? msg = Platform.isIOS
            ? message.notification?.title
            : message.notification?.body;

        if (msg == null) {
          return;
        }

        showDialog(
            context: navigatorKey.currentContext!,
            builder: (BuildContext context) {
              return ErrorDialog(
                type: DialogTypes.warning,
                title: "Alert",
                message: msg,
                buttonText: "Ok",
                buttonFn: () => Navigator.pop(context),
              );
            });
      }
    });

    _notifBackgroundSub = Push.instance.onBackgroundMessage.listen((message) {
      print('RemoteMessage received while app is in background:\n'
          'RemoteMessage.Notification: ${message.notification} \n'
          ' title: ${message.notification?.title.toString()}\n'
          ' body: ${message.notification?.body.toString()}\n'
          'RemoteMessage.Data: ${message.data}');
      //backgroundMessagesReceived.value += [message];
    });
  }

  void dispose() {
    _notifTapSub.cancel();
    _notifMessageSub.cancel();
    _notifBackgroundSub.cancel();
  }
}
