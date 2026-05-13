import '../../database/db_helper.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<int> addExpense(ExpenseModel expense) async {
    final db = await _dbHelper.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<double> getMonthlyExpenses(String monthYear) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date_time LIKE ?',
      ['$monthYear%'],
    );
    return result.first['total'] ?? 0.0;
  }

  Future<List<ExpenseModel>> getAllExpenses() async {
    final db = await _dbHelper.database;
    final result = await db.query('expenses', orderBy: 'date_time DESC');
    return result.map((json) => ExpenseModel.fromMap(json)).toList();
  }
}
