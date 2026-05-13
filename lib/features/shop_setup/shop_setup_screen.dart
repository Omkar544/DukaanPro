import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/shop_model.dart';
import '../../core/services/shop_setup_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/custom_text_field.dart';

class ShopSetupScreen extends StatefulWidget {
  const ShopSetupScreen({super.key});

  @override
  State<ShopSetupScreen> createState() => _ShopSetupScreenState();
}

class _ShopSetupScreenState extends State<ShopSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _addressController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final shop = ShopModel(
        shopName: _shopNameController.text,
        ownerName: _ownerNameController.text,
        phone: _phoneController.text,
        pin: _pinController.text,
        address: _addressController.text,
      );

      final success = await context.read<ShopSetupProvider>().registerShop(
        shop,
      );
      if (success && mounted) {
        // After setup, go to Dashboard
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup DukaanPro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Enter your business details to get started.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 25),
              CustomTextField(
                controller: _shopNameController,
                label: 'Shop Name',
                icon: Icons.store,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _ownerNameController,
                label: 'Owner Name',
                icon: Icons.person,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _pinController,
                label: 'Login PIN',
                icon: Icons.lock,
                isPassword: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),

              context.watch<ShopSetupProvider>().isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text(
                          "Create My Shop",
                          style: TextStyle(fontSize: 18, color: Colors.white),
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
