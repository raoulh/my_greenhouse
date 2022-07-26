import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:my_greenhouse/routes/routes.dart';
import 'package:my_greenhouse/services/auth_service.dart';
import 'package:my_greenhouse/services/connectivity_provider.dart';
import 'package:my_greenhouse/services/greenhouse_service.dart';
import 'package:my_greenhouse/services/lifecycle_service.dart';
import 'package:my_greenhouse/services/myfood_service.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    lifeCycleService = LifeCycleService();
    WidgetsBinding.instance.addObserver(lifeCycleService);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(lifeCycleService);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => GreenhouseService()),
        ChangeNotifierProvider(create: (_) => MyfoodService()),
        ChangeNotifierProvider(create: (_) => lifeCycleService),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyFood App',
        initialRoute: 'loading',
        onGenerateRoute: CustomRoutes.getRoutes,
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          Intl.defaultLocale = deviceLocale.toString();
          return deviceLocale;
        },
        locale: const Locale("fr", "FR"),
        localizationsDelegates: const [
          //MyLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // English
          Locale('fr', 'FR'), // French
        ],
      ),
    );
  }
}
