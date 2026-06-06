import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'core/services/auth_provider.dart';
import 'core/services/shop_setup_provider.dart';
import 'database/db_helper.dart'; // Imported to evaluate shop state at launch

void main() async {
  // FIX: Replaced the broken preview binding with standard Flutter core initialization
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DBHelper();
  final shopDetails = await dbHelper.getShopDetails();

  final String fallbackInitialRoute = shopDetails == null
      ? AppRoutes.register
      : AppRoutes.login;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShopSetupProvider()),
      ],
      child: DukaanProApp(startingRoute: fallbackInitialRoute),
    ),
  );
}

class DukaanProApp extends StatelessWidget {
  final String startingRoute;

  const DukaanProApp({super.key, required this.startingRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DukaanPro',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF6A5ACD),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A5ACD)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A5ACD),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      // Dynamic routing configuration based on current lifecycle states
      initialRoute: startingRoute,
      routes: AppRoutes.getRoutes(),
    );
  }
}
