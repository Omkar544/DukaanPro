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
  String _shopName =
      "Loading Workspace..."; // Informative dynamic default state

  @override
  void initState() {
    super.initState();
    _loadStoredPin();
  }

  void _loadStoredPin() async {
    final authRepo = AuthRepository();
    final shop = await authRepo.getShopDetails();
    if (shop != null) {
      setState(() {
        _storedPin = shop['pin']?.toString();
        _shopName = shop['shopName']?.toString() ?? "DukaanPro Workspace";
      });
      print("DEBUG: Loaded profile: $_shopName | Target PIN: $_storedPin");
    } else {
      // FIXED: If the SharedPreferences/SQLite cache is completely empty,
      // handle cleanly without forcing old hardcoded defaults.
      setState(() {
        _storedPin = null;
        _shopName = "Welcome to DukaanPro";
      });
      print("DEBUG: No store profile found in database storage.");
    }
  }

  // Strict PIN matching validation engine
  void _verifyPin() {
    final enteredPin = _pinController.text.trim();

    // FIXED: Removed hardcoded '123456' master bypass variable.
    // Validates strictly against the dynamically retrieved profile.
    if (_storedPin != null && enteredPin == _storedPin) {
      setState(() => _errorMessage = "");
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      setState(() {
        _errorMessage = _storedPin == null
            ? "No account found. Please register your shop below."
            : "Incorrect PIN. Try again.";
        _pinController.clear(); // Resets the field automatically on failure
      });
    }
  }

  void _handleForgotPin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Forgot PIN?"),
        content: Text(
          _storedPin == null
              ? "No shop has been registered on this system yet."
              : "For testing workspace configuration, the registered login code is: $_storedPin",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
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
            const Icon(
              Icons.lock_person_rounded,
              size: 85,
              color: Colors.white,
            ),
            const SizedBox(height: 15),

            // --- 🏪 DYNAMIC REGISTERED ACCOUNT NAME HEADER DISPLAY ---
            Text(
              _shopName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Enter Security PIN to Unlock Workspace",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 35),

            // --- 🔒 PREMIUM HIGH-CONTRAST TEXT INPUT FIELD ---
            TextField(
              controller: _pinController,
              obscureText: true,
              obscuringCharacter: '#',
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(
                color: Color(
                  0xFF117A85,
                ), // Rich dark teal text so '#' stands out boldly!
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: 16,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(
                  0.9,
                ), // Clean semi-transparent premium container background
                counterText: "",
                hintText: "######",
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  letterSpacing: 16,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.white, width: 2.5),
                ),
              ),
              onChanged: (val) {
                if (_errorMessage.isNotEmpty) {
                  setState(() => _errorMessage = "");
                }
              },
            ),

            // --- ⚠️ ERROR WARNING AREA ---
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.yellowAccent.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.yellowAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 35),

            // --- 🚀 VERIFY & LOGIN ACTION BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _verifyPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF12B8C4),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Verify & Login",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // --- 🔍 FORGOT PIN OPTION ---
            TextButton(
              onPressed: _handleForgotPin,
              child: const Text(
                "Forgot PIN?",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- 🏪 NAVIGATE TO REGISTRATION/SETUP SCREEN ---
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.register);
              },
              child: const Text(
                "New Store? Register / Setup Account",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
