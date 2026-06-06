import 'package:flutter/foundation.dart'; // REQUIRED for kIsWeb
import '../../database/db_helper.dart';

class AuthRepository {
  final DBHelper _dbHelper = DBHelper();

  // Insert a new shop record during registration
  Future<int> registerShop(Map<String, dynamic> shopData) async {
    // FIXED: Save the incoming data to local storage/shared preferences before advancing
    if (kIsWeb) {
      print(
        "WEB DEBUG: Saving profile configuration via repository engine: $shopData",
      );
      await _dbHelper.insertShopDetails(shopData);
      return 1; // Return successful verification flag token back up the chain
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
