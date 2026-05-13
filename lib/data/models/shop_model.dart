class ShopModel {
  final int? id;
  final String shopName;
  final String ownerName;
  final String phone;
  final String? gstNumber; // Optional for flexibility
  final String address;
  final String? logoPath; // Local path to the uploaded shop logo
  final String pin; // The security PIN used for login

  ShopModel({
    this.id,
    required this.shopName,
    required this.ownerName,
    required this.phone,
    this.gstNumber,
    required this.address,
    this.logoPath,
    required this.pin,
  });

  // Convert Shop object into a Map for SQLite 'users' table
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shop_name': shopName,
      'owner_name': ownerName,
      'phone': phone,
      'gst': gstNumber,
      'address': address,
      'logo_path': logoPath,
      'pin': pin,
    };
  }

  // Create a Shop object from a Database Map result
  factory ShopModel.fromMap(Map<String, dynamic> map) {
    return ShopModel(
      id: map['id'],
      shopName: map['shop_name'] ?? '',
      ownerName: map['owner_name'] ?? '',
      phone: map['phone'] ?? '',
      gstNumber: map['gst'],
      address: map['address'] ?? '',
      logoPath: map['logo_path'],
      pin: map['pin'] ?? '',
    );
  }
}
