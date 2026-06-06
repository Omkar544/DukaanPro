import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  // --- 🌐 WEB SIMULATION ENGINE RUNTIME PERSISTENCE TARGETS ---
  static double webSalesTotal = 0.0;
  static double webExpenseTotal = 0.0;

  // Dynamic runtime caches to hold database items live on Chrome
  static List<Map<String, dynamic>> webSalesItems = [];
  static List<Map<String, dynamic>> webTransactions = [];
  static List<Map<String, dynamic>> webExpenses = [];

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database?> _initDB() async {
    if (kIsWeb) return null;

    String path = join(await getDatabasesPath(), 'dukaanpro.db');
    return await openDatabase(
      path,
      version:
          2, // Upgraded database version to include itemized inventory tracking splits
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE shop_profile(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            shopName TEXT, ownerName TEXT, phone TEXT, pin TEXT, address TEXT, logoPath TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT, phone TEXT, amount REAL, paymentType TEXT,
            gstAmount REAL, totalAmount REAL, dateTime TEXT, isLocked INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE sales_items(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transactionId INTEGER, product TEXT, quantity REAL, rate REAL, total REAL, dateTime TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT, amount REAL, category TEXT, dateTime TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE sales_items(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              transactionId INTEGER, product TEXT, quantity REAL, rate REAL, total REAL, dateTime TEXT
            )
          ''');
        }
      },
    );
  }

  // --- 🏪 WEB-SAFE PROFILE INSERT ENGINE ---
  Future<int> insertShopDetails(Map<String, dynamic> map) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('shopName', map['shopName']?.toString() ?? '');
      await prefs.setString('ownerName', map['ownerName']?.toString() ?? '');
      await prefs.setString('phone', map['phone']?.toString() ?? '');
      await prefs.setString('pin', map['pin']?.toString() ?? '');
      await prefs.setString('address', map['address']?.toString() ?? '');
      await prefs.setString('logoPath', map['logoPath']?.toString() ?? '');

      // Reset runtime dashboard stats for clean workspace setup on initialization
      webSalesTotal = 0.0;
      webExpenseTotal = 0.0;
      webSalesItems.clear();
      webTransactions.clear();
      webExpenses.clear();
      return 1;
    }

    final db = await database;
    await db.delete(
      'shop_profile',
    ); // Keeps only one operational profile locally
    return await db.insert('shop_profile', map);
  }

  // --- 🔍 PULL DYNAMIC REGISTRATION VALUES ---
  Future<Map<String, dynamic>?> getShopDetails() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('shopName');

      // If nothing has been registered yet, return null so screens route to onboarding form smoothly
      if (savedName == null || savedName.isEmpty) return null;

      return {
        'shopName': prefs.getString('shopName'),
        'ownerName': prefs.getString('ownerName'),
        'phone': prefs.getString('phone'),
        'pin': prefs.getString('pin'),
        'address': prefs.getString('address'),
        'logoPath': prefs.getString('logoPath'),
      };
    }

    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('shop_profile');
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  // --- 🛍️ NEW ATOMIC INSIGHT WRITER: COMMITS INVOICE HEADERS ALONGSIDE ALL ITEM LINES ---
  Future<int> insertCustomerWithItems(
    Map<String, dynamic> txData,
    List<Map<String, dynamic>> itemsList,
  ) async {
    String timestamp = DateTime.now().toIso8601String();

    if (kIsWeb) {
      double billTotal = (txData['totalAmount'] ?? 0.0) as double;
      webSalesTotal += billTotal;

      txData['id'] = webTransactions.length + 1;
      txData['dateTime'] = timestamp;
      webTransactions.add(txData);

      for (var item in itemsList) {
        webSalesItems.add({
          'transactionId': txData['id'],
          'product': item['product'],
          'quantity': double.tryParse(item['quantity'].toString()) ?? 1.0,
          'rate': double.tryParse(item['rate'].toString()) ?? 0.0,
          'total': double.tryParse(item['total'].toString()) ?? 0.0,
          'dateTime': timestamp,
        });
      }
      print(
        "WEB DEBUG: Committed transaction #${txData['id']} with ${itemsList.length} item records.",
      );
      return 1;
    }

    final db = await database;
    // Execute atomic transaction map write
    int txId = await db.insert('transactions', txData);

    for (var item in itemsList) {
      await db.insert('sales_items', {
        'transactionId': txId,
        'product': item['product'],
        'quantity': item['quantity'],
        'rate': item['rate'],
        'total': item['total'],
        'dateTime': timestamp,
      });
    }
    return txId;
  }

  // --- 💸 INSERT EXPENSE / WHOLESALE BUY ---
  Future<int> insertExpense(Map<String, dynamic> map) async {
    map['dateTime'] = DateTime.now().toIso8601String();

    if (kIsWeb) {
      double buyCost = (map['amount'] ?? 0.0) as double;
      webExpenseTotal += buyCost;
      webExpenses.add(map);
      print(
        "WEB DEBUG: Added Expense! New Web Expense Total = ₹$webExpenseTotal",
      );
      return 1;
    }

    final db = await database;
    return await db.insert('expenses', map);
  }

  // --- 🧾 FETCH TRANSACTION RECORDS LIST ---
  Future<List<Map<String, dynamic>>> getTodayTransactions() async {
    if (kIsWeb) return webTransactions;

    final db = await database;
    String today = DateTime.now().toIso8601String().substring(0, 10);
    return await db.query(
      'transactions',
      where: "dateTime LIKE ?",
      whereArgs: ['$today%'],
    );
  }

  // --- 🔍 NEW METHOD: READ ITEMIZATIONS FOR THE PIE CHART ENGINE ---
  Future<List<Map<String, dynamic>>> getTodaySalesItems() async {
    if (kIsWeb) return webSalesItems;

    final db = await database;
    String today = DateTime.now().toIso8601String().substring(0, 10);
    return await db.query(
      'sales_items',
      where: "dateTime LIKE ?",
      whereArgs: ['$today%'],
    );
  }

  Future<List<Map<String, dynamic>>> getTodayExpenses() async {
    if (kIsWeb) return webExpenses;

    final db = await database;
    String today = DateTime.now().toIso8601String().substring(0, 10);
    return await db.query(
      'expenses',
      where: "dateTime LIKE ?",
      whereArgs: ['$today%'],
    );
  }

  // --- 📈 FETCH SUMMARY DATA LOG FOR DASHBOARD CARDS ---
  Future<Map<String, double>> getTodaySummary() async {
    if (kIsWeb) {
      return {'sales': webSalesTotal, 'expenses': webExpenseTotal};
    }

    final db = await database;
    String today = DateTime.now().toIso8601String().substring(0, 10);

    var salesRes = await db.rawQuery(
      "SELECT SUM(totalAmount) as total FROM transactions WHERE dateTime LIKE '$today%'",
    );
    var expRes = await db.rawQuery(
      "SELECT SUM(amount) as total FROM expenses WHERE dateTime LIKE '$today%'",
    );

    double totalSales = (salesRes.first['total'] ?? 0.0) as double;
    double totalExpenses = (expRes.first['total'] ?? 0.0) as double;

    return {'sales': totalSales, 'expenses': totalExpenses};
  }
}
