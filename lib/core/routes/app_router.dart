import 'package:flutter/material.dart';

// Import Screens
import '../../screens/splash_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/customer_entry_screen.dart';
import '../../screens/reports_screen.dart';
import '../../screens/expense_screen.dart';
import '../../screens/settings_screen.dart';

import 'app_routes.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes {
    return {
      AppRoutes.splash: (context) => const SplashScreen(),
      AppRoutes.login: (context) => const LoginScreen(),
      AppRoutes.register: (context) => const RegisterScreen(),
      AppRoutes.dashboard: (context) => const DashboardScreen(),
      AppRoutes.customerEntry: (context) => const CustomerEntryScreen(),
      AppRoutes.reports: (context) => const ReportsScreen(),
      AppRoutes.expense: (context) => const ExpenseScreen(),
      AppRoutes.settings: (context) => const SettingsScreen(),
    };
  }
}