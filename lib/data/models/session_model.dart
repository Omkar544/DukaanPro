class SessionModel {
  final int? id;
  final String date; // Format: YYYY-MM-DD
  final double totalSales;
  final double totalExpenses;
  final double netProfit;
  final String closingNotes;
  final int isLocked; // 1 = Closed/Locked, 0 = Active

  SessionModel({
    this.id,
    required this.date,
    required this.totalSales,
    required this.totalExpenses,
    required this.netProfit,
    this.closingNotes = "",
    this.isLocked = 0,
  });

  // Convert Session object into a Map for SQLite 'daily_summary' table
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'total_sales': totalSales,
      'total_expense': totalExpenses,
      'net_profit': netProfit,
      'notes': closingNotes,
      'locked': isLocked,
    };
  }

  // Create Session object from a Database Map
  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'],
      date: map['date'] ?? '',
      totalSales: (map['total_sales'] ?? 0.0).toDouble(),
      totalExpenses: (map['total_expense'] ?? 0.0).toDouble(),
      netProfit: (map['net_profit'] ?? 0.0).toDouble(),
      closingNotes: map['notes'] ?? "",
      isLocked: map['locked'] ?? 0,
    );
  }
}
