import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:domini/services/auth_service.dart';
import 'package:domini/screens/home/home_screen.dart';
import 'package:domini/screens/auth/setup_pin_screen.dart';
import 'package:domini/widgets/pin_keyboard.dart';
import 'package:domini/widgets/pin_display.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> with SingleTickerProviderStateMixin {
  final List<int> _enteredPin = [];
  bool _isError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
        }
      });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPressed(int digit) {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (_enteredPin.length < authService.pinLength) {
      setState(() {
        _enteredPin.add(digit);
        _isError = false;
      });

      // Check if PIN is complete
      if (_enteredPin.length == authService.pinLength) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin.removeLast();
        _isError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final String pin = _enteredPin.join();
    
    final bool isValid = await authService.verifyPin(pin);
    
    if (isValid) {
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
        _enteredPin.clear();
      });
      _shakeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final bool isPinSet = authService.isPinSet;
    final int pinLength = authService.pinLength;

    if (!isPinSet) {
      return const SetupPinScreen();
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              'Enter PIN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value * (_shakeController.status == AnimationStatus.reverse ? -1 : 1), 0),
                  child: child,
                );
              },
              child: PinDisplay(
                pinLength: pinLength,
                enteredDigits: _enteredPin.length,
                isError: _isError,
              ),
            ),
            const Spacer(),
            PinKeyboard(
              onKeyPressed: _onKeyPressed,
              onDeletePressed: _onDeletePressed,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
