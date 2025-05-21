import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:domini/services/database_service.dart';
import 'package:domini/services/theme_service.dart';
import 'package:domini/screens/auth/setup_pin_screen.dart';

class ForgotPinScreen extends StatefulWidget {
  const ForgotPinScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends State<ForgotPinScreen> {
  final TextEditingController _securityAnswerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';
  int _remainingAttempts = 3; // Limit to 3 attempts
  String _securityQuestion = 'Loading security question...';
  bool _isLoadingQuestion = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityQuestion();
  }

  Future<void> _loadSecurityQuestion() async {
    setState(() {
      _isLoadingQuestion = true;
    });
    
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final question = await databaseService.getSecurityQuestion();
    
    if (mounted) {
      setState(() {
        _isLoadingQuestion = false;
        _securityQuestion = question != null && question.isNotEmpty 
            ? question 
            : 'No security question found. Please contact support.';
      });
    }
  }

  Future<void> _verifySecurityAnswer() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final answer = _securityAnswerController.text.trim();
    
    try {
      final isCorrect = await databaseService.verifySecurityAnswer(answer);
      
      if (mounted) {
        if (isCorrect) {
          // Navigate to reset PIN screen
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              builder: (context) => const SetupPinScreen(isReset: true),
            ),
          );
        } else {
          _remainingAttempts--;
          setState(() {
            _isLoading = false;
            _errorMessage = 'Incorrect answer. Please try again.';
            
            if (_remainingAttempts <= 0) {
              _errorMessage = 'Too many failed attempts. Please contact support.';
              // Disable the button
              _remainingAttempts = 0;
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred. Please try again later.';
        });
      }
    }
  }

  @override
  void dispose() {
    _securityAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = themeService.isDarkMode;
    
    // iOS-like colors
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final accentColor = const Color(0xFF007AFF); // iOS blue
    final errorColor = const Color(0xFFFF3B30); // iOS red
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Forgot PIN',
          style: TextStyle(color: textColor),
        ),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: accentColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoadingQuestion
              ? Center(child: CircularProgressIndicator(color: accentColor))
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Security Question',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isDarkMode ? [] : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _securityQuestion,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: textColor.withOpacity(0.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Your Answer',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _securityAnswerController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Enter your answer',
                          hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: accentColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: errorColor, width: 2),
                          ),
                          errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                          errorStyle: TextStyle(color: errorColor),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your answer';
                          }
                          return null;
                        },
                      ),
                      if (_remainingAttempts < 3) ...[  
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.exclamationmark_triangle,
                              color: _remainingAttempts == 1 ? errorColor : Colors.orange,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remaining attempts: $_remainingAttempts',
                              style: TextStyle(
                                color: _remainingAttempts == 1 ? errorColor : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _remainingAttempts <= 0 || _isLoading ? null : _verifySecurityAnswer,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: accentColor.withOpacity(0.5),
                          disabledForegroundColor: Colors.white.withOpacity(0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Verify Answer',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
