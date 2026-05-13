class ExpenseModel {
  final int? id;
  final String category;
  final double amount;
  final String notes;
  final DateTime dateTime;

  ExpenseModel({
    this.id,
    required this.category,
    required this.amount,
    required this.notes,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'notes': notes,
      'date_time': dateTime.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      notes: map['notes'] ?? '',
      dateTime: DateTime.parse(map['date_time']),
    );
  }
}
