import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:domini/services/auth_service.dart';
import 'package:domini/services/theme_service.dart';
import 'package:domini/screens/home/home_screen.dart';
import 'package:domini/widgets/pin_keyboard.dart';
import 'package:domini/widgets/pin_display.dart';
import 'package:domini/screens/auth/username_setup_screen.dart';

class SetupPinScreen extends StatefulWidget {
  final bool isReset;
  
  const SetupPinScreen({
    Key? key,
    this.isReset = false,
  }) : super(key: key);

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final List<int> _enteredPin = [];
  final List<int> _confirmPin = [];
  bool _isConfirming = false;
  bool _isError = false;
  late String _headerText;
  late String _subHeaderText;
  
  @override
  void initState() {
    super.initState();
    _updateHeaderText();
  }
  
  void _updateHeaderText() {
    if (widget.isReset) {
      _headerText = _isConfirming ? 'Confirm New PIN' : 'Create New PIN';
      _subHeaderText = _isConfirming 
          ? 'Re-enter your new PIN to confirm' 
          : 'Enter a 6-digit PIN to replace your old one';
    } else {
      _headerText = _isConfirming ? 'Confirm PIN' : 'Create PIN';
      _subHeaderText = _isConfirming 
          ? 'Re-enter your PIN to confirm' 
          : 'Enter a 6-digit PIN to secure your notes';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = themeService.isDarkMode;
    final int pinLength = authService.pinLength;

    // iOS-like colors
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final keyColor = isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final accentColor = const Color(0xFF007AFF); // iOS blue
    final errorColor = const Color(0xFFFF3B30); // iOS red

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          widget.isReset ? 'Reset PIN' : 'Setup PIN',
          style: TextStyle(color: textColor),
        ),
        leading: _isConfirming
            ? IconButton(
                icon: Icon(CupertinoIcons.back, color: accentColor),
                onPressed: () {
                  setState(() {
                    _isConfirming = false;
                    _confirmPin.clear();
                    _isError = false;
                    _headerText = 'Create PIN';
                    _subHeaderText = 'Enter a $pinLength-digit PIN to secure your notes';
                  });
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              _headerText,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _subHeaderText,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            PinDisplay(
              pinLength: pinLength,
              enteredDigits: _isConfirming ? _confirmPin.length : _enteredPin.length,
              isError: _isError,
              filledColor: _isError ? errorColor : accentColor,
              emptyColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
            ),
            const Spacer(),
            PinKeyboard(
              onKeyPressed: (digit) => _onKeyPressed(digit, pinLength),
              onDeletePressed: _onDeletePressed,
              keyColor: keyColor,
              textColor: textColor,
              deleteColor: errorColor,
              useGlassmorphism: isDarkMode,
              fontSize: 28,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _onKeyPressed(int digit, int pinLength) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final int pinLength = authService.pinLength;
    
    if (!_isConfirming) {
      // First PIN entry
      if (_enteredPin.length < pinLength) {
        setState(() {
          _enteredPin.add(digit);
        });

        // Check if PIN is complete
        if (_enteredPin.length == pinLength) {
          setState(() {
            _isConfirming = true;
            _updateHeaderText();
          });
        }
      }
    } else {
      if (_confirmPin.length < pinLength) {
        setState(() {
          _confirmPin.add(digit);
          _isError = false;
        });

        // Check if confirmation PIN is complete
        if (_confirmPin.length == pinLength) {
          _verifyPins();
        }
      }
    }
  }

  void _onDeletePressed() {
    if (_isConfirming) {
      if (_confirmPin.isNotEmpty) {
        setState(() {
          _confirmPin.removeLast();
          _isError = false;
        });
      }
    } else {
      if (_enteredPin.isNotEmpty) {
        setState(() {
          _enteredPin.removeLast();
        });
      }
    }
  }

  Future<void> _verifyPins() async {
    final String pin = _enteredPin.join();
    final String confirmPin = _confirmPin.join();

    if (pin == confirmPin) {
      await _savePin();
    } else {
      setState(() {
        _isError = true;
        _confirmPin.clear();
      });
    }
  }
  
  Future<void> _savePin() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final String pin = _enteredPin.join();
    
    await authService.setPin(pin);
    await _resetFailedAttempts(); // Reset any failed attempts when setting a new PIN
    
    if (mounted) {
      // Show success message for PIN reset
      if (widget.isReset) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN has been successfully reset'),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to home screen after PIN reset
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        // For new PIN setup, navigate to username setup
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const UsernameSetupScreen(),
          ),
        );
      }
    }
  }
  
  Future<void> _resetFailedAttempts() async {
    // In a real app, you would reset the failed attempts here
    // This is just a simulation for the demo
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
