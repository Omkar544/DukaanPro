import 'package:flutter/material.dart';
// Update these imports to point to 'features' instead of 'screens'
import '../../features/splash/splash_screen.dart';
import '../../features/auth/pin_lock_screen.dart'; // Corrected location
import '../../features/shop_setup/shop_setup_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/fast_entry/fast_entry_screen.dart';
import '../../features/reports/daily_report_screen.dart';
import '../../features/expenses/expense_list_screen.dart';
import '../../features/settings/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String customerEntry = '/customer-entry';
  static const String reports = '/reports';
  static const String expense = '/expense';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const PinLockScreen(), // Pointed to your new PIN screen
      register: (context) => const ShopSetupScreen(), // Pointed to your setup screen
      dashboard: (context) => const DashboardScreen(),
      customerEntry: (context) => const FastEntryScreen(),
      reports: (context) => const DailyReportScreen(),
      expense: (context) => const ExpenseListScreen(),
      settings: (context) => const SettingsScreen(),
    };
  }
}