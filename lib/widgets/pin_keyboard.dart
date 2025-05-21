import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class PinKeyboard extends StatelessWidget {
  final Function(int) onKeyPressed;
  final VoidCallback onDeletePressed;
  final bool biometricEnabled;
  final VoidCallback? onBiometricPressed;
  final Color? keyColor;
  final Color? textColor;
  final Color? biometricColor;
  final Color? deleteColor;
  final double buttonSize;
  final double fontSize;
  final bool useGlassmorphism;

  const PinKeyboard({
    Key? key,
    required this.onKeyPressed,
    required this.onDeletePressed,
    this.biometricEnabled = false,
    this.onBiometricPressed,
    this.keyColor,
    this.textColor,
    this.biometricColor,
    this.deleteColor,
    this.buttonSize = 80,
    this.fontSize = 30,
    this.useGlassmorphism = false,
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
    final defaultKeyColor = isDarkMode 
        ? const Color.fromARGB(255, 50, 50, 56)
        : Colors.grey.shade200;
    final defaultTextColor = isDarkMode ? Colors.white : Colors.black87;
    
    return Container(
      width: buttonSize,
      height: buttonSize,
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
            borderRadius: BorderRadius.circular(buttonSize / 2),
            child: Container(
              decoration: BoxDecoration(
                color: keyColor?.withOpacity(0.8) ?? defaultKeyColor.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: useGlassmorphism ? [] : [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: useGlassmorphism ? Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ) : null,
                gradient: useGlassmorphism ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ) : null,
              ),
              child: Center(
                child: Text(
                  digit.toString(),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? defaultTextColor,
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
    final defaultKeyColor = isDarkMode 
        ? const Color.fromARGB(255, 50, 50, 56)
        : Colors.grey.shade200;
    final defaultDeleteColor = isDarkMode ? Colors.redAccent.shade200 : Colors.redAccent.shade400;
    
    return Container(
      width: buttonSize,
      height: buttonSize,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onDeletePressed();
          },
          borderRadius: BorderRadius.circular(buttonSize / 2),
          child: Container(
            decoration: BoxDecoration(
              color: keyColor?.withOpacity(0.8) ?? defaultKeyColor.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: useGlassmorphism ? [] : [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: useGlassmorphism ? Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ) : null,
              gradient: useGlassmorphism ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ) : null,
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.delete_left_fill,
                size: buttonSize * 0.35,
                color: deleteColor?.withOpacity(0.8) ?? defaultDeleteColor.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultKeyColor = isDarkMode 
        ? const Color.fromARGB(255, 50, 50, 56)
        : Colors.grey.shade200;
    final defaultBiometricColor = isDarkMode ? Colors.green.shade400 : Colors.green.shade600;
    
    return Container(
      width: buttonSize,
      height: buttonSize,
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
            borderRadius: BorderRadius.circular(buttonSize / 2),
            child: Container(
              decoration: BoxDecoration(
                color: keyColor?.withOpacity(0.8) ?? defaultKeyColor.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: useGlassmorphism ? [] : [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: useGlassmorphism ? Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ) : null,
                gradient: useGlassmorphism ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ) : null,
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.person_crop_circle_fill_badge_checkmark,
                  size: buttonSize * 0.35,
                  color: biometricColor ?? defaultBiometricColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
