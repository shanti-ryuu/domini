import 'package:flutter/material.dart';
import 'package:domini/services/database_service.dart';

class AuthService extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  bool _isAuthenticated = false;
  bool _isPinSet = false;
  int _pinLength = 6;
  bool _biometricEnabled = false;
  bool _isPinLocked = false;
  String _securityQuestion = '';

  AuthService() {
    _checkPinStatus();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isPinSet => _isPinSet;
  int get pinLength => _pinLength;
  bool get biometricEnabled => _biometricEnabled;
  bool get isPinLocked => _isPinLocked;
  String get securityQuestion => _securityQuestion;

  Future<void> _checkPinStatus() async {
    _isPinSet = await _databaseService.isPinSet();
    final settings = await _databaseService.getSettings();
    if (settings != null) {
      _pinLength = settings.pinLength;
      _biometricEnabled = settings.biometricEnabled;
      _isPinLocked = settings.isPinLocked;
      _securityQuestion = settings.securityQuestion;
    }
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    // Check if PIN is locked due to too many failed attempts
    final settings = await _databaseService.getSettings();
    if (settings == null) return false;
    
    if (settings.isPinLocked) {
      // Check if lockout period has passed (30 minutes)
      if (settings.lastFailedAttempt != null) {
        final lockoutDuration = const Duration(minutes: 30);
        final now = DateTime.now();
        final lockoutEnd = settings.lastFailedAttempt!.add(lockoutDuration);
        
        if (now.isBefore(lockoutEnd)) {
          // Still in lockout period
          return false;
        } else {
          // Lockout period ended, reset the counter
          await _resetFailedAttempts();
        }
      }
    }
    
    final isValid = _databaseService.verifyPin(pin);
    
    if (isValid) {
      // Reset failed attempts on successful login
      await _resetFailedAttempts();
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } else {
      // Increment failed attempts
      await _incrementFailedAttempts();
      return false;
    }
  }

  Future<void> setPin(String pin) async {
    await _databaseService.setPin(pin);
    _isPinSet = true;
    _isAuthenticated = true;
    await _resetFailedAttempts(); // Reset any failed attempts when setting a new PIN
    notifyListeners();
  }

  Future<void> changePin(String newPin) async {
    await _databaseService.setPin(newPin);
    await _resetFailedAttempts(); // Reset any failed attempts when changing PIN
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

  Future<void> logout() async {
    _isAuthenticated = false;
    notifyListeners();
  }
  
  // Security question methods
  Future<void> setSecurityQuestion(String question, String answer) async {
    await _databaseService.setSecurityQuestion(question, answer);
    _securityQuestion = question;
    notifyListeners();
  }
  
  Future<bool> verifySecurityAnswer(String answer) async {
    return await _databaseService.verifySecurityAnswer(answer);
  }
  
  // PIN security methods
  Future<void> _incrementFailedAttempts() async {
    final settings = await _databaseService.getSettings();
    if (settings == null) return;
    
    final failedAttempts = settings.failedPinAttempts + 1;
    final now = DateTime.now();
    
    // Lock PIN after 5 failed attempts
    final isPinLocked = failedAttempts >= 5;
    
    await _databaseService.updateSettings(
      settings.copyWith(
        failedPinAttempts: failedAttempts,
        lastFailedAttempt: now,
        isPinLocked: isPinLocked,
      ),
    );
    
    _isPinLocked = isPinLocked;
    notifyListeners();
  }
  
  Future<void> _resetFailedAttempts() async {
    final settings = await _databaseService.getSettings();
    if (settings == null) return;
    
    await _databaseService.updateSettings(
      settings.copyWith(
        failedPinAttempts: 0,
        lastFailedAttempt: null,
        isPinLocked: false,
      ),
    );
    
    _isPinLocked = false;
    notifyListeners();
  }
  
  // Get remaining lockout time in minutes
  Future<int> getRemainingLockoutTime() async {
    final settings = await _databaseService.getSettings();
    if (settings == null || !settings.isPinLocked || settings.lastFailedAttempt == null) {
      return 0;
    }
    
    final lockoutDuration = const Duration(minutes: 30);
    final now = DateTime.now();
    final lockoutEnd = settings.lastFailedAttempt!.add(lockoutDuration);
    
    if (now.isAfter(lockoutEnd)) {
      return 0;
    }
    
    return lockoutEnd.difference(now).inMinutes + 1; // Add 1 to round up
  }
}
