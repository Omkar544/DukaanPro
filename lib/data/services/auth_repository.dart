import 'package:flutter/foundation.dart'; // REQUIRED for kIsWeb
import '../../database/db_helper.dart';

class AuthRepository {
  final DBHelper _dbHelper = DBHelper();

  // Insert a new shop record during registration
  Future<int> registerShop(Map<String, dynamic> shopData) async {
    // WEB FALLBACK: Bypass SQLite file writing on Chrome so the UI proceeds
    if (kIsWeb) {
      print("WEB DEBUG: Registration button clicked with data: $shopData");
      return 1; // Return a fake successful row ID (e.g., 1) to trick the provider
    }

    // Native Mobile Execution
    final db = await _dbHelper.database;
    return await db.insert('shop_profile', shopData);
  }

  // Fetch raw shop details
  Future<Map<String, dynamic>?> getShopDetails() async {
    return await _dbHelper.getShopDetails();
  }

  // Check registration status
  Future<bool> isShopRegistered() async {
    final shop = await getShopDetails();
    return shop != null;
  }
}
