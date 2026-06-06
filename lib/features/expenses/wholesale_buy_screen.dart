import 'package:flutter/material.dart';
import '../../database/db_helper.dart';

class WholesaleBuyScreen extends StatefulWidget {
  const WholesaleBuyScreen({super.key});

  @override
  State<WholesaleBuyScreen> createState() => _WholesaleBuyScreenState();
}

class _WholesaleBuyScreenState extends State<WholesaleBuyScreen> {
  final _titleController = TextEditingController();
  final _costController = TextEditingController();
  String _category = 'Inventory Stock';

  void _commitWholesaleBuy() async {
    if (_titleController.text.isNotEmpty && _costController.text.isNotEmpty) {
      Map<String, dynamic> wholesaleRow = {
        'title': "[WHOLESALE BUY] ${_titleController.text}",
        'amount': double.parse(_costController.text),
        'category': _category,
        'dateTime': DateTime.now().toIso8601String(),
      };

      await DBHelper().insertExpense(wholesaleRow);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wholesale Stock Inflow Intake")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Batch Product Procurement Details",
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _costController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Total Supply Cost Amount (₹)",
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _commitWholesaleBuy,
                child: const Text("Log Wholesale Stock Purchase"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
