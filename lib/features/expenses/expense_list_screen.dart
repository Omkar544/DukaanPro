import 'package:flutter/material.dart';
import '../../database/db_helper.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Stock Purchase';

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> row = {
        'title': _titleController.text,
        'amount': double.parse(_amountController.text),
        'category': _category,
        'dateTime': DateTime.now().toIso8601String()
      };
      await DBHelper().insertExpense(row);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Expense Logged!")));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log Business Expense")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Expense Description / Title", prefixIcon: Icon(Icons.description)),
                validator: (val) => val!.isEmpty ? "Describe the expense" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount Spent (₹)", prefixIcon: Icon(Icons.currency_rupee)),
                validator: (val) => val!.isEmpty ? "Enter cost value" : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _category,
                items: ['Stock Purchase', 'Rent & Utilities', 'Salaries', 'Miscellaneous']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
                decoration: const InputDecoration(labelText: "Category", prefixIcon: Icon(Icons.category)),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(onPressed: _saveExpense, child: const Text("Log Outflow")),
              )
            ],
          ),
        ),
      ),
    );
  }
}