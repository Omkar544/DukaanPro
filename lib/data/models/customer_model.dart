class CustomerModel {
  final int? id;
  final String name;
  final String? phone;
  final double amount;
  final String paymentType; // Cash, UPI, Card
  final double gstAmount;
  final double totalAmount;
  final DateTime dateTime;
  final int isLocked; // 0 = Editable, 1 = Locked (Closed Day)

  CustomerModel({
    this.id,
    required this.name,
    this.phone,
    required this.amount,
    required this.paymentType,
    this.gstAmount = 0.0,
    required this.totalAmount,
    required this.dateTime,
    this.isLocked = 0,
  });

  // Convert a Customer object into a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'amount': amount,
      'payment_type': paymentType,
      'gst_amount': gstAmount,
      'total_amount': totalAmount,
      'date_time': dateTime.toIso8601String(),
      'is_locked': isLocked,
    };
  }

  // Extract a Customer object from a Database Map
  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'],
      name: map['name'] ?? '',
      phone: map['phone'],
      amount: (map['amount'] ?? 0.0).toDouble(),
      paymentType: map['payment_type'] ?? 'Cash',
      gstAmount: (map['gst_amount'] ?? 0.0).toDouble(), // Fixed parameter name
      totalAmount: (map['total_amount'] ?? 0.0).toDouble(),
      dateTime: DateTime.parse(map['date_time']),
      isLocked: map['is_locked'] ?? 0,
    );
  
}
}
