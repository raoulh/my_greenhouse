import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:my_greenhouse/routes/routes.dart';
import 'package:my_greenhouse/services/auth_service.dart';
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
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        //ChangeNotifierProvider(create: (_) => SocketService()),
        //ChangeNotifierProvider(create: (_) => ChatService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyFood App',
        initialRoute: 'dashboard',
        routes: appRoutes,
      ),
    );
  }
}
