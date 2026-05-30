import 'package:flutter/material.dart';
import '../../data/models/customer_model.dart';
import '../../database/db_helper.dart';

class FastEntryScreen extends StatefulWidget {
  const FastEntryScreen({super.key});

  @override
  State<FastEntryScreen> createState() => _FastEntryScreenState();
}

class _FastEntryScreenState extends State<FastEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedPaymentType = 'Cash';
  final List<String> _paymentTypes = ['Cash', 'UPI', 'Card'];
  bool _isSaving = false;

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      double rawAmount = double.parse(_amountController.text);
      // Optional: If you want to calculate a standard 18% GST baseline dynamically
      double gstBase = 0.18;
      double gstAmount = rawAmount * gstBase;
      double totalAmount = rawAmount + gstAmount;

      final newCustomerSale = CustomerModel(
        name: _nameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        amount: rawAmount,
        paymentType: _selectedPaymentType,
        gstAmount: gstAmount,
        totalAmount: totalAmount,
        dateTime: DateTime.now(),
        isLocked: 0, // 0 means editable until the business day closes
      );

      try {
        // Accessing your database helper singleton
        final db = DBHelper();
        // Assuming your DBHelper has an insertCustomer dynamic function or similar method name
        await db.insertCustomer(newCustomerSale.toMap());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("⚡ Transaction saved for ${_nameController.text}!"),
              backgroundColor: Colors.green,
            ),
          );
          // Clear inputs for next quick entry
          _nameController.clear();
          _phoneController.clear();
          _amountController.clear();
          setState(() => _selectedPaymentType = 'Cash');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error saving: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fast Entry")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Quick Sale Entry",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A5ACD),
                ),
              ),
              const SizedBox(height: 20),

              // Customer Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Customer Name *",
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) => val!.isEmpty ? "Enter customer name" : null,
              ),
              const SizedBox(height: 15),

              // Phone Field (Optional)
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number (Optional)",
                  prefixIcon: const Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Base Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Sale Amount (₹) *",
                  prefixIcon: const Icon(Icons.currency_rupee),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Enter amount";
                  if (double.tryParse(val) == null)
                    return "Enter a valid number";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Payment Mode Selection Segment
              const Text(
                "Payment Method",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                children: _paymentTypes.map((type) {
                  bool isSelected = _selectedPaymentType == type;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Center(child: Text(type)),
                        selected: isSelected,
                        selectedColor: const Color(0xFF6A5ACD),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        onSelected: (bool selected) {
                          if (selected) {
                            setState(() => _selectedPaymentType = type);
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),

              // Action Button
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveTransaction,
                        child: const Text(
                          "Save Entry",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
