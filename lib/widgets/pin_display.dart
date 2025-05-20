import 'package:flutter/material.dart';
import 'package:domini/constants/app_colors.dart';

class PinDisplay extends StatelessWidget {
  final int pinLength;
  final int enteredDigits;
  final bool isError;

  const PinDisplay({
    super.key,
    required this.pinLength,
    required this.enteredDigits,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pinLength,
        (index) {
          final bool isActive = index < enteredDigits;
          
          Color dotColor;
          if (isError) {
            dotColor = AppColors.errorLight;
          } else if (isActive) {
            dotColor = isDarkMode ? AppColors.primaryDark : AppColors.primaryLight;
          } else {
            dotColor = isDarkMode ? AppColors.pinDotInactive.withOpacity(0.5) : AppColors.pinDotInactive;
          }
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }
}
