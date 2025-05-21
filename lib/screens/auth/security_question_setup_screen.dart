import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:domini/services/auth_service.dart';
import 'package:domini/constants/app_colors.dart';
import 'package:domini/screens/home/home_screen.dart';

class SecurityQuestionSetupScreen extends StatefulWidget {
  final bool isAfterPinSetup;
  
  const SecurityQuestionSetupScreen({
    Key? key,
    this.isAfterPinSetup = true,
  }) : super(key: key);

  @override
  State<SecurityQuestionSetupScreen> createState() => _SecurityQuestionSetupScreenState();
}

class _SecurityQuestionSetupScreenState extends State<SecurityQuestionSetupScreen> {
  final TextEditingController _securityAnswerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedQuestion = '';
  
  // List of predefined security questions
  final List<String> _securityQuestions = [
    'What was the name of your first pet?',
    'In what city were you born?',
    'What is your mother\'s maiden name?',
    'What high school did you attend?',
    'What was the make of your first car?',
    'What is your favorite movie?',
    'What is the name of your favorite childhood teacher?',
    'What is your favorite book?',
  ];
  
  @override
  void initState() {
    super.initState();
    // Set default selected question
    _selectedQuestion = _securityQuestions[0];
  }
  
  @override
  void dispose() {
    _securityAnswerController.dispose();
    super.dispose();
  }
  
  Future<void> _saveSecurityQuestion() async {
    if (!_formKey.currentState!.validate()) {
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
    
    try {
      // Save security question and answer
      await authService.setSecurityQuestion(_selectedQuestion, answer);
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Security question saved successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to home screen or back
        if (widget.isAfterPinSetup) {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to save security question. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Question'),
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
                          Icons.security,
                          color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Security Setup',
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
                      'Set up a security question to help you reset your PIN if you forget it. Choose a question and provide an answer that you\'ll remember.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose a security question:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedQuestion,
                              dropdownColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                              items: _securityQuestions.map((String question) {
                                return DropdownMenuItem<String>(
                                  value: question,
                                  child: Text(
                                    question,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedQuestion = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Your answer:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _securityAnswerController,
                          decoration: InputDecoration(
                            hintText: 'Enter your answer',
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
                            if (value.trim().length < 2) {
                              return 'Answer must be at least 2 characters';
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
                            onPressed: _saveSecurityQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Save Security Question',
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
}
