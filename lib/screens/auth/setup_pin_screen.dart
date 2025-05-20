import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:domini/services/auth_service.dart';
import 'package:domini/screens/home/home_screen.dart';
import 'package:domini/widgets/pin_keyboard.dart';
import 'package:domini/widgets/pin_display.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final List<int> _enteredPin = [];
  final List<int> _confirmPin = [];
  bool _isConfirming = false;
  bool _isError = false;
  String _headerText = 'Create PIN';
  String _subHeaderText = 'Enter a 6-digit PIN to secure your notes';

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final int pinLength = authService.pinLength;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup PIN'),
        leading: _isConfirming
            ? IconButton(
                icon: const Icon(CupertinoIcons.back),
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
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _subHeaderText,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            PinDisplay(
              pinLength: pinLength,
              enteredDigits: _isConfirming ? _confirmPin.length : _enteredPin.length,
              isError: _isError,
            ),
            const Spacer(),
            PinKeyboard(
              onKeyPressed: (digit) => _onKeyPressed(digit, pinLength),
              onDeletePressed: _onDeletePressed,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _onKeyPressed(int digit, int pinLength) {
    if (_isConfirming) {
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
    } else {
      if (_enteredPin.length < pinLength) {
        setState(() {
          _enteredPin.add(digit);
        });

        // Check if initial PIN is complete
        if (_enteredPin.length == pinLength) {
          setState(() {
            _isConfirming = true;
            _headerText = 'Confirm PIN';
            _subHeaderText = 'Re-enter your PIN to confirm';
          });
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
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.setPin(pin);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } else {
      setState(() {
        _isError = true;
        _confirmPin.clear();
      });
    }
  }
}
