import '../../database/db_helper.dart';
import '../models/session_model.dart';

class SessionRepository {
  final DBHelper _dbHelper = DBHelper.instance;

  Future<int> saveDailySummary(SessionModel session) async {
    final db = await _dbHelper.database;
    return await db.insert('daily_summary', session.toMap());
  }

  Future<bool> isDayLocked(String date) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'daily_summary',
      where: 'date = ? AND locked = 1',
      whereArgs: [date],
    );
    return result.isNotEmpty;
  }
}
