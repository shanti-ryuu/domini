import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:domini/services/auth_service.dart';
import 'package:domini/constants/app_colors.dart';
import 'package:domini/screens/auth/setup_pin_screen.dart';
import 'package:domini/screens/auth/pin_screen.dart';

class ForgotPinScreen extends StatefulWidget {
  const ForgotPinScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends State<ForgotPinScreen> {
  final TextEditingController _securityAnswerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showSecurityQuestion = false;
  String _securityQuestion = '';
  String _errorMessage = '';
  int _remainingAttempts = 3;
  bool _isLocked = false;
  DateTime? _lockoutEndTime;
  
  @override
  void initState() {
    super.initState();
    _loadSecurityQuestion();
  }
  
  @override
  void dispose() {
    _securityAnswerController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSecurityQuestion() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    // Check if PIN is locked due to too many failed attempts
    final remainingLockoutTime = await authService.getRemainingLockoutTime();
    if (remainingLockoutTime > 0) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLocked = true;
          _lockoutEndTime = DateTime.now().add(Duration(minutes: remainingLockoutTime));
        });
        return;
      }
    }
    
    // Get the security question from the auth service
    final securityQuestion = authService.securityQuestion;
    
    // If no security question is set, show an error
    if (securityQuestion.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No security question has been set up. Please contact support.';
        });
      }
      return;
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _showSecurityQuestion = true;
        _securityQuestion = securityQuestion;
      });
    }
  }
  
  Future<void> _verifySecurityAnswer() async {
    if (!_formKey.currentState!.validate() || _isLocked) {
      return;
    }
    
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final answer = _securityAnswerController.text.trim();
    
    // Add a small delay for security (prevents timing attacks)
    // Use a fixed delay plus a variable component based on answer length
    await Future.delayed(Duration(milliseconds: 800 + (50 * answer.length)));
    
    // Verify the security answer with the auth service
    final isValid = await authService.verifySecurityAnswer(answer);
    
    if (mounted) {
      if (isValid) {
        // Success - navigate to PIN setup screen
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const SetupPinScreen(
              isReset: true,
            ),
          ),
        );
      } else {
        // Decrement remaining attempts
        _remainingAttempts--;
        
        // Check if we've reached the maximum number of attempts
        if (_remainingAttempts <= 0) {
          setState(() {
            _isLoading = false;
            _isLocked = true;
            _lockoutEndTime = DateTime.now().add(const Duration(minutes: 30));
            _errorMessage = 'Too many failed attempts. Try again in 30 minutes.';
          });
          
          // Navigate back to PIN screen after a delay
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                  builder: (context) => const PinScreen(),
                ),
              );
            }
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Incorrect answer. Please try again. '
                '${_remainingAttempts} ${_remainingAttempts == 1 ? 'attempt' : 'attempts'} remaining.';
          });
        }
        
        // Haptic feedback for error
        HapticFeedback.vibrate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // If the account is locked, show a countdown timer
    if (_isLocked && _lockoutEndTime != null) {
      final now = DateTime.now();
      if (now.isBefore(_lockoutEndTime!)) {
        final remainingMinutes = _lockoutEndTime!.difference(now).inMinutes + 1;
        _errorMessage = 'Too many failed attempts. Try again in $remainingMinutes minutes.';
      } else {
        // Lockout period ended
        setState(() {
          _isLocked = false;
          _remainingAttempts = 3;
          _errorMessage = '';
        });
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset PIN'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 90,
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
                          Positioned(bottom: 15, left: 15, child: _buildDot()),
                          Positioned(bottom: 15, right: 15, child: _buildDot()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'DomiNotes',
                      style: TextStyle(
                        fontSize: 24,
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
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PIN Reset',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'To reset your PIN, please answer your security question below. After verification, you\'ll be able to set a new PIN.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              if (_errorMessage.isNotEmpty && !_showSecurityQuestion)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (_showSecurityQuestion)
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Question:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _securityQuestion,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _securityAnswerController,
                          decoration: InputDecoration(
                            labelText: 'Your Answer',
                            filled: true,
                            fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
                                width: 2,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your answer';
                            }
                            return null;
                          },
                        ),
                        
                        if (_errorMessage.isNotEmpty && _showSecurityQuestion)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                        const Spacer(),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLocked ? null : _verifySecurityAnswer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Verify & Reset PIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDot() {
    return Container(
      width: 8,
      height: 8,
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
