import 'package:flutter/material.dart';
import '../../data/services/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> checkRegistration() async {
    return await _authRepo.isShopRegistered();
  }
}
