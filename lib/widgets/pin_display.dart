import 'package:flutter/material.dart';
import 'package:domini/constants/app_colors.dart';
import 'dart:math' as math;

class PinDisplay extends StatelessWidget {
  final int pinLength;
  final int enteredDigits;
  final bool isError;
  final bool isVerifying;

  const PinDisplay({
    Key? key,
    required this.pinLength,
    required this.enteredDigits,
    this.isError = false,
    this.isVerifying = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pinLength,
        (index) {
          final bool isActive = index < enteredDigits;
          
          return _buildPinDot(context, index, isActive, isDarkMode);
        },
      ),
    );
  }

  Widget _buildPinDot(BuildContext context, int index, bool isActive, bool isDarkMode) {
    Color dotColor;
    double size = 16.0;
    
    if (isVerifying && isActive) {
      dotColor = isDarkMode ? Colors.blue.shade700 : Colors.blue.shade500;
      size = 18.0;
    } else if (isActive) {
      dotColor = isError
          ? Colors.red
          : isDarkMode
              ? AppColors.primaryDark
              : AppColors.primaryLight;
      size = 18.0;
    } else {
      dotColor = isDarkMode
          ? AppColors.pinDotInactive.withOpacity(0.5) 
          : AppColors.pinDotInactive;
      size = 16.0;
    }
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
        boxShadow: isActive ? [
          BoxShadow(
            color: dotColor.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ] : null,
      ),
      child: isError && isActive ? _buildErrorAnimation() : null,
    );
  }

  Widget _buildErrorAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (0.2 * (math.sin(value * 2 * math.pi))),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
