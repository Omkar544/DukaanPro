import 'package:flutter/material.dart';
import '../../data/services/auth_repository.dart';
import '../../data/models/shop_model.dart';

class ShopSetupProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> registerShop(ShopModel shop) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepo.registerShop(shop);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
