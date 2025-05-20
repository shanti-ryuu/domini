import 'package:flutter/material.dart';
import 'package:domini/services/database_service.dart';

class AuthService extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  bool _isAuthenticated = false;
  bool _isPinSet = false;
  int _pinLength = 6;
  bool _biometricEnabled = false;

  AuthService() {
    _checkPinStatus();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isPinSet => _isPinSet;
  int get pinLength => _pinLength;
  bool get biometricEnabled => _biometricEnabled;

  Future<void> _checkPinStatus() async {
    _isPinSet = await _databaseService.isPinSet();
    final settings = await _databaseService.getSettings();
    if (settings != null) {
      _pinLength = settings.pinLength;
      _biometricEnabled = settings.biometricEnabled;
    }
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    final isValid = _databaseService.verifyPin(pin);
    if (isValid) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return isValid;
  }

  Future<void> setPin(String pin) async {
    await _databaseService.setPin(pin);
    _isPinSet = true;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> changePin(String newPin) async {
    await _databaseService.setPin(newPin);
    notifyListeners();
  }

  Future<void> setPinLength(int length) async {
    if (length == 4 || length == 6) {
      _pinLength = length;
      final settings = await _databaseService.getSettings();
      if (settings != null) {
        settings.pinLength = length;
        await _databaseService.updateSettings(settings);
        notifyListeners();
      }
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    final settings = await _databaseService.getSettings();
    if (settings != null) {
      settings.biometricEnabled = enabled;
      await _databaseService.updateSettings(settings);
      notifyListeners();
    }
  }

  void signOut() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
