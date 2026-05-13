import 'package:flutter/material.dart';
import '../../data/services/auth_repository.dart';
import '../../core/routes/app_routes.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _errorMessage = "";
  String? _storedPin;

  @override
  void initState() {
    super.initState();
    _loadStoredPin();
  }

  void _loadStoredPin() async {
    final authRepo = AuthRepository();
    final shop = await authRepo.getShopDetails();
    if (shop != null) {
      setState(() => _storedPin = shop.pin);
      // Helpful for debugging in the VS Code console
      print("DEBUG: The PIN in database is: ${shop.pin}");
    }
  }

  void _verifyPin() {
    if (_pinController.text == _storedPin) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      setState(() {
        _errorMessage = "Incorrect PIN. Try again.";
        _pinController.clear();
      });
    }
  }

  void _handleForgotPin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Forgot PIN?"),
        content: const Text(
          "For security, enter the 4-digit test OTP (1234) to reveal your current PIN.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _sendOtpMock();
              Navigator.pop(context);
            },
            child: const Text(
              "Send OTP (Mock)",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  void _sendOtpMock() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP sent! Use '1234' for testing.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12B8C4),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_open_outlined, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "Enter 6-Digit PIN",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _pinController,
              // UPDATED: Set to false so you can see the code while entering
              obscureText: false,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              // UPDATED: Changed to 6 for your PIN 416115
              maxLength: 6,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 10,
              ),
              decoration: InputDecoration(
                counterText: "",
                hintText: "000000",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2),
                ),
              ),
              onChanged: (val) {
                // UPDATED: Automatically verify when 6 digits are entered
                if (val.length == 6) _verifyPin();
              },
            ),

            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.yellowAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),
            TextButton(
              onPressed: _handleForgotPin,
              child: const Text(
                "Forgot PIN?",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
