import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// These imports are updated to match your new 'data' folder structure
import '../data/models/customer_model.dart';
import '../data/models/expense_model.dart';
import '../data/models/shop_model.dart';
import '../data/models/session_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dukaanpro.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Users/Shop Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_name TEXT,
        owner_name TEXT,
        phone TEXT,
        pin TEXT,
        address TEXT,
        logo_path TEXT,
        gst TEXT
      )
    ''');

    // Customers Table
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        amount REAL,
        payment_type TEXT,
        gst_amount REAL,
        total_amount REAL,
        date_time TEXT,
        is_locked INTEGER DEFAULT 0
      )
    ''');

    // Expenses Table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT,
        amount REAL,
        notes TEXT,
        date_time TEXT
      )
    ''');

    // Daily Summary Table
    await db.execute('''
      CREATE TABLE daily_summary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        total_sales REAL,
        total_expense REAL,
        net_profit REAL,
        notes TEXT,
        locked INTEGER DEFAULT 0
      )
    ''');
  }

  // --- Customer Operations ---

  Future<int> insertCustomer(CustomerModel customer) async {
    final db = await instance.database;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<CustomerModel>> getAllCustomers() async {
    final db = await instance.database;
    final result = await db.query('customers', orderBy: 'date_time DESC');
    return result.map((json) => CustomerModel.fromMap(json)).toList();
  }

  // --- Close Day Logic ---

  Future<int> lockDailyData(String date) async {
    final db = await instance.database;
    return await db.update(
      'customers',
      {'is_locked': 1},
      where: 'date_time LIKE ?',
      whereArgs: ['$date%'],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}