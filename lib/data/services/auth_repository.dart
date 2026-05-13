import '../../database/db_helper.dart';
import '../models/shop_model.dart';

class AuthRepository {
  final DBHelper _dbHelper = DBHelper.instance;

  // --- SHOP REGISTRATION ---
  
  /// Saves the shop details during the first-time setup.
  Future<int> registerShop(ShopModel shop) async {
    final db = await _dbHelper.database;
    return await db.insert('users', shop.toMap());
  }

  // --- LOGIN & SECURITY ---

  /// Verifies if the entered PIN matches the owner's stored PIN.
  Future<bool> verifyPin(String phone, String enteredPin) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'phone = ? AND pin = ?',
      whereArgs: [phone, enteredPin],
    );
    return result.isNotEmpty;
  }

  /// Checks if a shop is already registered on this device.
  Future<bool> isShopRegistered() async {
    final db = await _dbHelper.database;
    final result = await db.query('users');
    return result.isNotEmpty;
  }

  /// Retrieves the current Shop profile for the dashboard and reports.
  Future<ShopModel?> getShopDetails() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);
    
    if (maps.isNotEmpty) {
      return ShopModel.fromMap(maps.first);
    }
    return null;
  }
}