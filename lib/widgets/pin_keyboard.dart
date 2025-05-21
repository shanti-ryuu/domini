import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class PinKeyboard extends StatelessWidget {
  final Function(int) onKeyPressed;
  final VoidCallback onDeletePressed;
  final bool biometricEnabled;
  final VoidCallback? onBiometricPressed;

  const PinKeyboard({
    Key? key,
    required this.onKeyPressed,
    required this.onDeletePressed,
    this.biometricEnabled = false,
    this.onBiometricPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeyButton(1, context),
              _buildKeyButton(2, context),
              _buildKeyButton(3, context),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeyButton(4, context),
              _buildKeyButton(5, context),
              _buildKeyButton(6, context),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeyButton(7, context),
              _buildKeyButton(8, context),
              _buildKeyButton(9, context),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              biometricEnabled && onBiometricPressed != null
                ? _buildBiometricButton(context)
                : Container(width: 80, height: 80), // Empty space
              _buildKeyButton(0, context),
              _buildDeleteButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyButton(int digit, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 200 + (digit * 30)),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onKeyPressed(digit);
            },
            borderRadius: BorderRadius.circular(40),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Color.fromARGB(255, 50, 50, 56).withOpacity(0.8)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  digit.toString(),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final errorColor = isDarkMode ? Colors.redAccent.shade200 : Colors.redAccent.shade400;
    
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onDeletePressed();
          },
          borderRadius: BorderRadius.circular(40),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Color.fromARGB(255, 50, 50, 56).withOpacity(0.8)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.delete_left_fill,
                size: 28,
                color: errorColor.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? Colors.green.shade400 : Colors.green.shade600;
    
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              onBiometricPressed?.call();
            },
            borderRadius: BorderRadius.circular(40),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Color.fromARGB(255, 50, 50, 56).withOpacity(0.8)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.person_crop_circle_fill_badge_checkmark,
                  size: 28,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
