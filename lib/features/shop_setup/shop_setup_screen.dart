import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/shop_model.dart';
import '../../core/services/shop_setup_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/custom_text_field.dart';
import '../../database/db_helper.dart'; // Added database connection layer link

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

  // Selected default asset icon configuration for the shop logo
  IconData _selectedLogoIcon = Icons.storefront_rounded;

  final List<IconData> _availableLogos = [
    Icons.storefront_rounded,
    Icons.shopping_bag_rounded,
    Icons.local_grocery_store_rounded,
    Icons.add_business_rounded,
    Icons.restaurant_rounded,
  ];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final shop = ShopModel(
        shopName: _shopNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        phone: _phoneController.text.trim(),
        pin: _pinController.text.trim(),
        address: _addressController.text.trim(),
        logoPath: _selectedLogoIcon.codePoint.toString(),
      );

      // 1. Convert the data model values into an operational Database map array
      Map<String, dynamic> profileMap = {
        'shopName': shop.shopName,
        'ownerName': shop.ownerName,
        'phone': shop.phone,
        'pin': shop.pin,
        'address': shop.address,
        'logoPath': shop.logoPath,
      };

      // 2. FIXED: Push profile parameters straight down into Web-Safe SharedPreferences / Local SQLite
      await DBHelper().insertShopDetails(profileMap);

      // 3. Trigger your state providers architecture loops
      final success = await context.read<ShopSetupProvider>().registerShop(shop);

      if (success && mounted) {
        // FIXED: Change destination path to prompt login validation testing right away!
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _addressController.dispose();
    super.dispose();
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

              // --- 📸 SHOP LOGO SELECTION SECTOR ---
              const Text(
                "Select Your Shop Branding Logo",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFF6A5ACD).withOpacity(0.1),
                  child: Icon(
                    _selectedLogoIcon,
                    size: 45,
                    color: const Color(0xFF6A5ACD),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Horizontal selector row to choose a custom business profile icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _availableLogos.map((icon) {
                  final bool isSelected = _selectedLogoIcon == icon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedLogoIcon = icon),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF6A5ACD) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.grey.shade300,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 24,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // --- FORM ENTRY TEXTFIELDS ---
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
              const SizedBox(height: 35),

              // --- SUBMIT ACTION ENGINE ---
              context.watch<ShopSetupProvider>().isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            child: const Text(
                              "Create My Shop",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- 🔗 LOGIN NAVIGATION DEVIATION LINK ---
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                          child: const Text(
                            "Already have a shop? Login with PIN",
                            style: TextStyle(
                              color: Color(0xFF6A5ACD),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}