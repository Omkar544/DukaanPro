import 'package:flutter/material.dart';
import '../../database/db_helper.dart';

class LineItem {
  String productName;
  int? quantity; 
  double? rate; 
  bool isCustom;

  LineItem({
    required this.productName,
    this.quantity,
    this.rate,
    this.isCustom = false,
  });

  double get total => (quantity ?? 0) * (rate ?? 0.0);
}

class FastEntryScreen extends StatefulWidget {
  const FastEntryScreen({super.key});

  @override
  State<FastEntryScreen> createState() => _FastEntryScreenState();
}

class _FastEntryScreenState extends State<FastEntryScreen> {
  // Initial item row in basket starts completely empty
  final List<LineItem> _cart = [
    LineItem(productName: '', quantity: null, rate: null),
  ];

  // --- 🛒 CLEAN RETAIL LIST ---
  final List<String> _dailyUseProducts = [
    'Premium Basmati Rice',
    'Kolam Rice',
    'Chakki Fresh Atta',
    'Maida',
    'Suji / Rawa',
    'Toor Dal / Arhar Dal',
    'Moong Dal Premium',
    'Chana Dal',
    'Kabuli Chana',
    'Fortune Sunflower Oil',
    'Saffola Gold Blended Oil',
    'Sweekar Refined Rice Bran Oil',
    'Pure Cow Ghee',
    'Mustard Oil',
    'Tata Salt Iodized',
    'Everest Garam Masala',
    'Catch Turmeric Powder',
    'MDH Kashmiri Chilly Powder',
    'Sugar Premium M Quality',
    'Amul Taaza Toned Milk',
    'Amul Pasteurised Salted Butter',
    'Amul Pure Dahi / Curd',
    'Britannia Sandwich Sliced Bread',
    'Nandini Premium Curd Pack',
    'Maggi 2-Minute Masala Noodles',
    'Parle-G Gluco Biscuits',
    'Britannia Good Day Cashew Cookies',
    'Haldiram Nagpur Bhujia Sev',
    'Cadbury Dairy Milk Silk Chocolate',
    'Kissan Fresh Tomato Ketchup',
    'Taj Mahal Tea Premium Dust',
    'Nescafe Classic Instant Coffee',
    'Dettol Liquid Handwash Refill',
    'Lifebuoy Total Soap Bar',
    'Dove Cream Beauty Bathing Bar',
    'Colgate Strong Teeth Toothpaste',
    'Clinic Plus Strong & Long Shampoo',
    'Pears Pure & Gentle Soap',
    'Surf Excel Easy Wash Detergent',
    'Vim Dishwash Liquid Lemon Gel',
    'Rin Detergent Bar',
    'Harpic Disinfectant Toilet Cleaner',
    'Lizol Disinfectant Floor Cleaner',
    'Colin Surface Cleaner Spray',
    'Garbage Disposal Bags',
  ];

  bool _applyGST = false;
  Map<String, dynamic>? _shopProfile;

  double get _subTotal => _cart.fold(0, (sum, item) => sum + item.total);
  double get _gstAmount => _applyGST ? (_subTotal * 0.18) : 0.0;
  double get _grandTotal => _subTotal + _gstAmount;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final data = await DBHelper().getShopDetails();
    setState(() => _shopProfile = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Customer Bill")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Profile Identification Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF6A5ACD).withOpacity(0.1),
                    radius: 30,
                    child: const Icon(
                      Icons.storefront,
                      color: Color(0xFF6A5ACD),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _shopProfile?['shopName'] ?? "Mahalaxmi Kirana Stores",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "📍 ${_shopProfile?['address'] ?? 'Jaysingpur'} | 📞 ${_shopProfile?['phone'] ?? '9876543210'}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Basket Items Ledger Line",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cart.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        // --- 📝 DROP-DOWN / CUSTOM TYPING SWITCH PANEL ---
                        Expanded(
                          flex: 3,
                          child: _cart[index].isCustom
                              ? TextFormField(
                                  initialValue: _cart[index].productName,
                                  decoration: const InputDecoration(
                                    hintText: "Enter Product Name",
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    border: UnderlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  onChanged: (val) =>
                                      _cart[index].productName = val,
                                )
                              : DropdownButton<String>(
                                  value: _cart[index].productName.isEmpty
                                      ? null
                                      : _cart[index].productName,
                                  hint: const Text(
                                    "Select Product",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  items: _dailyUseProducts
                                      .map(
                                        (p) => DropdownMenuItem(
                                          value: p,
                                          child: Text(
                                            p,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) => setState(
                                    // FIXED: Triggers a smooth recalculation context update upon choosing
                                    () => _cart[index].productName = val!,
                                  ),
                                ),
                        ),

                        IconButton(
                          icon: Icon(
                            _cart[index].isCustom
                                ? Icons.list_alt_rounded
                                : Icons.edit_note_rounded,
                            color: const Color(0xFF6A5ACD),
                            size: 22,
                          ),
                          tooltip: _cart[index].isCustom
                              ? "Select from list"
                              : "Type custom product",
                          onPressed: () {
                            setState(() {
                              _cart[index].isCustom = !_cart[index].isCustom;
                              _cart[index].productName = ""; 
                            });
                          },
                        ),
                        const SizedBox(width: 4),

                        // Quantity Input Layout
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            key: UniqueKey(), 
                            initialValue:
                                _cart[index].quantity?.toString() ?? "",
                            decoration: const InputDecoration(
                              hintText: "Qty",
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: (val) => setState(
                              () => _cart[index].quantity = int.tryParse(val),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Rate Input Layout
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            key: UniqueKey(), 
                            initialValue: _cart[index].rate?.toString() ?? "",
                            decoration: const InputDecoration(
                              hintText: "Rate ₹",
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: (val) => setState(
                              () => _cart[index].rate = double.tryParse(val),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            if (_cart.length > 1) {
                              setState(() => _cart.removeAt(index));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                TextButton.icon(
                  onPressed: () => setState(
                    () => _cart.add(
                      LineItem(productName: "", quantity: null, rate: null),
                    ),
                  ),
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    color: Color(0xFF6A5ACD),
                  ),
                  label: const Text(
                    "Add Product",
                    style: TextStyle(
                      color: Color(0xFF6A5ACD),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: () => setState(
                    () => _cart.add(
                      LineItem(
                        productName: "",
                        quantity: null,
                        rate: null,
                        isCustom: true,
                      ),
                    ),
                  ),
                  icon: const Icon(
                    Icons.playlist_add_sharp,
                    color: Colors.teal,
                  ),
                  label: const Text(
                    "➕ Custom Item",
                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            // GST Toggle Selector
            SwitchListTile(
              title: const Text("Apply GST Tax (18%)"),
              subtitle: const Text(
                "Toggle parameter to inject standard calculations",
              ),
              value: _applyGST,
              activeColor: const Color(0xFF6A5ACD),
              onChanged: (val) => setState(() => _applyGST = val),
            ),
            const Divider(),

            // Calculation Panel Readouts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sub Total:"),
                Text("₹${_subTotal.toStringAsFixed(2)}"),
              ],
            ),
            const SizedBox(height: 6),
            if (_applyGST) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("GST (18%):"),
                  Text("₹${_gstAmount.toStringAsFixed(2)}"),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Bill Amount:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹${_grandTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF6A5ACD),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _finalizeBill,
                icon: const Icon(Icons.receipt_long),
                label: const Text(
                  "Generate & Save Invoice Ledger",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🛍️ FIXED: BREAK OUT INDIVIDUAL ITEMS TO TRACK QUANTITIES CORRECTLY ---
  void _finalizeBill() async {
    // 1. Build the high-level invoice metadata record map
    Map<String, dynamic> checkoutRow = {
      'name': 'Counter Customer',
      'amount': _subTotal,
      'gstAmount': _gstAmount,
      'totalAmount': _grandTotal,
      'paymentType': 'Cash/UPI',
      'isLocked': 0,
    };

    // 2. Parse basket line collections into separate structured item rows
    List<Map<String, dynamic>> targetItemsList = [];
    for (var lineItem in _cart) {
      if (lineItem.productName.isNotEmpty && (lineItem.quantity ?? 0) > 0) {
        targetItemsList.add({
          'product': lineItem.productName,
          'quantity': lineItem.quantity ?? 1,
          'rate': lineItem.rate ?? 0.0,
          'total': lineItem.total,
        });
      }
    }

    if (targetItemsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot compile or save an empty checkout basket!"),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    // 3. Atomically commit both transaction headers and split product line records
    await DBHelper().insertCustomerWithItems(checkoutRow, targetItemsList);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Receipt saved successfully into daily books!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}