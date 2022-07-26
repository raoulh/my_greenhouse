import 'package:flutter/material.dart';
import 'package:my_greenhouse/services/connectivity_provider.dart';

import 'package:my_greenhouse/ui/page/login_page.dart';
import 'package:my_greenhouse/ui/page/dashboard_page.dart';
import 'package:my_greenhouse/ui/page/loading_page.dart';
import 'package:my_greenhouse/ui/page/no_internet_page.dart';
import 'package:my_greenhouse/ui/page/no_route_page.dart';
import 'package:provider/provider.dart';

class CustomRoutes {
  static Route<dynamic> getRoutes(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) {
      final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;

      if (!isOnline) {
        return const NoInternetPage();
      }

      switch (settings.name) {
        case 'login':
          return const LoginPage();
        case 'loading':
          return const LoadingPage();
        case 'dashboard':
          return const DashboardPage();
      }

      return const NoRoutePage();
    });
  }
}
