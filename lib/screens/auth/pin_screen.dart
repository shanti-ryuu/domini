import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:domini/services/auth_service.dart';
import 'package:domini/screens/home/home_screen.dart';
import 'package:domini/screens/auth/setup_pin_screen.dart';
import 'package:domini/screens/auth/forgot_pin_screen.dart';
import 'package:domini/widgets/pin_keyboard.dart';
import 'package:domini/widgets/pin_display.dart';
import 'package:domini/constants/app_colors.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> with SingleTickerProviderStateMixin {
  final List<int> _enteredPin = [];
  bool _isError = false;
  bool _isVerifying = false;
  bool _biometricAvailable = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  final ValueNotifier<bool> _showLogo = ValueNotifier<bool>(true);

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
      
    // Hide logo after a delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _showLogo.value = false;
      }
    });
    
    // Check if biometric authentication is available
    _checkBiometricAvailability();
  }
  
  Future<void> _checkBiometricAvailability() async {
    // In a real app, you would check if the device supports biometric auth
    // For this demo, we'll just simulate it's available
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _biometricAvailable = true;
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _showLogo.dispose();
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
    // Show verifying state
    setState(() {
      _isVerifying = true;
    });
    
    // Add haptic feedback
    HapticFeedback.mediumImpact();
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final String pin = _enteredPin.join();
    
    // Simulate network delay for verification
    await Future.delayed(const Duration(milliseconds: 600));
    
    final bool isValid = await authService.verifyPin(pin);
    
    if (isValid) {
      if (mounted) {
        // Success haptic feedback
        HapticFeedback.heavyImpact();
        
        // Navigate with a fade transition
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } else {
      if (mounted) {
        // Error haptic feedback
        HapticFeedback.vibrate();
        
        setState(() {
          _isVerifying = false;
          _isError = true;
          _enteredPin.clear();
        });
        _shakeController.forward();
      }
    }
  }
  
  void _onBiometricPressed() async {
    // Simulate biometric authentication
    HapticFeedback.mediumImpact();
    
    setState(() {
      _isVerifying = true;
    });
    
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (mounted) {
      HapticFeedback.heavyImpact();
      
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final bool isPinSet = authService.isPinSet;
    final int pinLength = authService.pinLength;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (!isPinSet) {
      return const SetupPinScreen();
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // App logo with animation
            ValueListenableBuilder<bool>(
              valueListenable: _showLogo,
              builder: (context, showLogo, _) {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOutCubic,
                  top: showLogo ? MediaQuery.of(context).size.height * 0.15 : 30,
                  left: 0,
                  right: 0,
                  height: showLogo ? 200 : 140,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: showLogo ? 1.0 : 0.9,
                    child: Center(
                      child: _buildAppLogo(isDarkMode),
                    ),
                  ),
                );
              },
            ),
            
            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: _showLogo.value ? 0.0 : 1.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode 
                          ? [Colors.black54, Colors.black38]
                          : [Colors.white70, Colors.white54],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Enter PIN',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black87,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'to access your notes',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
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
                    isVerifying: _isVerifying,
                  ),
                ),
                const Spacer(),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _isVerifying ? 0.5 : 1.0,
                  child: IgnorePointer(
                    ignoring: _isVerifying,
                    child: PinKeyboard(
                      onKeyPressed: _onKeyPressed,
                      onDeletePressed: _onDeletePressed,
                      biometricEnabled: _biometricAvailable,
                      onBiometricPressed: _onBiometricPressed,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Forgot PIN option
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _isVerifying ? 0.0 : 1.0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode 
                          ? [Colors.blueGrey.shade800, Colors.blueGrey.shade900]
                          : [Colors.blueGrey.shade100, Colors.blueGrey.shade200],
                      ),
                    ),
                    child: TextButton(
                      onPressed: _isVerifying ? null : () {
                        // Navigate to forgot PIN screen
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const ForgotPinScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        'Forgot PIN?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
            
            // Loading overlay
            if (_isVerifying)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      width: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDarkMode 
                            ? [Colors.black87, Colors.black54]
                            : [Colors.white, Colors.white70],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDarkMode ? AppColors.primaryDark : AppColors.primaryLight
                              ),
                              strokeWidth: 4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Verifying...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppLogo(bool isDarkMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Domino logo
        Container(
          width: _showLogo.value ? 80 : 60,
          height: _showLogo.value ? 120 : 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode 
                ? [AppColors.primaryDark, Color(0xFF1A4D80)]
                : [AppColors.primaryLight, Color(0xFF2E86C1)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Dividing line
              Center(
                child: Container(
                  width: double.infinity,
                  height: 3,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              // Dots pattern
              Positioned(top: 15, left: 15, child: _buildDot()),
              Positioned(top: 15, right: 15, child: _buildDot()),
              Positioned(top: 45, left: 15, child: _buildDot()),
              Positioned(top: 45, right: 15, child: _buildDot()),
              Positioned(bottom: 45, left: 15, child: _buildDot()),
              Positioned(bottom: 45, right: 15, child: _buildDot()),
              Positioned(bottom: 15, left: 15, child: _buildDot()),
              Positioned(bottom: 15, right: 15, child: _buildDot()),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // App name
        Text(
          'DomiNotes',
          style: TextStyle(
            fontSize: _showLogo.value ? 36 : 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: isDarkMode 
                  ? [AppColors.primaryDark, Color(0xFF64B5F6)]
                  : [AppColors.primaryLight, Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );
  }
}
