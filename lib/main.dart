import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:my_greenhouse/routes/routes.dart';
import 'package:my_greenhouse/services/auth_service.dart';
import 'package:my_greenhouse/services/connectivity_provider.dart';
import 'package:my_greenhouse/services/greenhouse_service.dart';
import 'package:my_greenhouse/services/lifecycle_service.dart';
import 'package:my_greenhouse/services/myfood_service.dart';
import 'package:my_greenhouse/services/notif_handler.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(const MyApp());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late LifeCycleService lifeCycleService;
  late NotifHandler notifHandler;
  late GreenhouseService greenhouseService;

  @override
  void initState() {
    super.initState();
    notifHandler = NotifHandler();
    lifeCycleService = LifeCycleService();
    WidgetsBinding.instance.addObserver(lifeCycleService);
    greenhouseService = GreenhouseService();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(lifeCycleService);
    notifHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => greenhouseService),
        ChangeNotifierProvider(create: (_) => MyfoodService()),
        ChangeNotifierProvider(create: (_) => lifeCycleService),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => notifHandler),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: 'MyFood App',
        initialRoute: 'loading',
        onGenerateRoute: CustomRoutes.getRoutes,
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          Intl.defaultLocale = deviceLocale.toString();
          return deviceLocale;
        },
        locale: const Locale("fr", "FR"),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          RefreshLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('fr', 'FR'), // French
        ],
      ),
    );
  }
}
