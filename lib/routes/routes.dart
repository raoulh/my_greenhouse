import 'package:flutter/material.dart';

import 'package:my_greenhouse/ui/page/login_page.dart';
import 'package:my_greenhouse/ui/page/dashboard_page.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  'login': (_) => const LoginPage(),
  'dashboard': (_) => const DashboardPage(),
//  'loading': (_) => const LoadingPage(),
};
