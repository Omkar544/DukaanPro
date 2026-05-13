import '../../database/db_helper.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final DBHelper _dbHelper = DBHelper.instance;

  // --- SAVE TRANSACTION ---
  Future<int> addCustomerEntry(CustomerModel customer) async {
    final db = await _dbHelper.database;
    return await db.insert('customers', customer.toMap());
  }

  // --- DASHBOARD DATA ---
  Future<double> getTodayTotalSales(String date) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(total_amount) as total FROM customers WHERE date_time LIKE ?',
      ['$date%'],
    );
    return result.first['total'] ?? 0.0;
  }

  Future<List<CustomerModel>> getRecentTransactions() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      orderBy: 'date_time DESC',
      limit: 10,
    );
    return maps.map((item) => CustomerModel.fromMap(item)).toList();
  }
}
