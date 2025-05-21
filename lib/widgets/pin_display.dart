import 'package:flutter/material.dart';
import 'package:domini/constants/app_colors.dart';
import 'dart:math' as math;

class PinDisplay extends StatelessWidget {
  final int pinLength;
  final int enteredDigits;
  final bool isError;
  final bool isVerifying;
  final Color? filledColor;
  final Color? emptyColor;
  final double dotSize;
  final double spacing;

  const PinDisplay({
    Key? key,
    required this.pinLength,
    required this.enteredDigits,
    this.isError = false,
    this.isVerifying = false,
    this.filledColor,
    this.emptyColor,
    this.dotSize = 16.0,
    this.spacing = 16.0,
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
    double size = dotSize;
    
    if (isVerifying && isActive) {
      dotColor = filledColor ?? (isDarkMode ? Colors.blue.shade700 : Colors.blue.shade500);
      size = dotSize * 1.125;
    } else if (isActive) {
      dotColor = isError
          ? (filledColor ?? Colors.red)
          : filledColor ?? (isDarkMode
              ? AppColors.primaryDark
              : AppColors.primaryLight);
      size = dotSize * 1.125;
    } else {
      dotColor = emptyColor ?? (isDarkMode
          ? Colors.grey.shade800
          : Colors.grey.shade300);
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: spacing / 2),
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: dotColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
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
