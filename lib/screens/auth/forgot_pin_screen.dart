import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:domini/services/database_service.dart';
import 'package:domini/constants/app_colors.dart';
import 'package:domini/screens/auth/setup_pin_screen.dart';

class ForgotPinScreen extends StatefulWidget {
  const ForgotPinScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends State<ForgotPinScreen> {
  final TextEditingController _securityAnswerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // Used in _verifySecurityAnswer method
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
        _securityQuestion = question != null && question.isNotEmpty ? question : 'No security question found. Please contact support.';
      });
    }
  }

  @override
  void dispose() {
    _securityAnswerController.dispose();
    super.dispose();
  }

  Future<void> _verifySecurityAnswer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_remainingAttempts <= 0) {
      setState(() {
        _errorMessage = 'Too many failed attempts. Please try again later.';
      });
      return;
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final answer = _securityAnswerController.text.trim();

    // Simulate verification with a delay (anti-timing attack measure)
    await Future.delayed(Duration(milliseconds: 500 + (answer.length * 10)));

    // Verify the security answer
    final bool isCorrect = await databaseService.verifySecurityAnswer(answer);

    if (isCorrect) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const SetupPinScreen(isReset: true),
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _remainingAttempts--;
          _errorMessage = 'Incorrect answer. $_remainingAttempts attempts remaining.';
          _securityAnswerController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot PIN'),
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
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDarkMode
                              ? [AppColors.primaryDark, Color(0xFF1A4D80)]
                              : [AppColors.primaryLight, Color(0xFF2E86C1)],
                        ),
                        shape: BoxShape.circle,
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
                        alignment: Alignment.center,
                        children: [
                          // Note icon
                          Icon(
                            Icons.note_alt_outlined,
                            color: Colors.white,
                            size: 35,
                          ),
                          // Circular border
                          Container(
                            width: 63,
                            height: 63,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
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

              const SizedBox(height: 30),

              if (_isLoadingQuestion)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  Icons.security,
                                  color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Security Question',
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
                              _securityQuestion,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _securityAnswerController,
                              decoration: InputDecoration(
                                labelText: 'Answer',
                                labelStyle: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
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
                            if (_errorMessage.isNotEmpty)
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
                                onPressed: _verifySecurityAnswer,
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
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  

}
