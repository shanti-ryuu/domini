import 'package:flutter/material.dart';

class DominoIconPainter extends CustomPainter {
  final Color backgroundColor;
  final Color dotColor;

  DominoIconPainter({
    required this.backgroundColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final Paint dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    // Draw domino background (rounded rectangle)
    final RRect dominoRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.2),
    );
    canvas.drawRRect(dominoRect, backgroundPaint);

    // Draw dividing line
    final Paint linePaint = Paint()
      ..color = dotColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;
    
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      linePaint,
    );

    // Draw dots (3 on top, 4 on bottom - like a domino)
    final double dotRadius = size.width * 0.08;
    final double padding = size.width * 0.15;
    
    // Top section - 3 dots
    // Top left
    canvas.drawCircle(
      Offset(padding, padding),
      dotRadius,
      dotPaint,
    );
    
    // Top center
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 4),
      dotRadius,
      dotPaint,
    );
    
    // Top right
    canvas.drawCircle(
      Offset(size.width - padding, padding),
      dotRadius,
      dotPaint,
    );
    
    // Bottom section - 4 dots
    // Bottom left
    canvas.drawCircle(
      Offset(padding, size.height - padding),
      dotRadius,
      dotPaint,
    );
    
    // Bottom right
    canvas.drawCircle(
      Offset(size.width - padding, size.height - padding),
      dotRadius,
      dotPaint,
    );
    
    // Bottom center left
    canvas.drawCircle(
      Offset(size.width / 3, size.height * 3 / 4),
      dotRadius,
      dotPaint,
    );
    
    // Bottom center right
    canvas.drawCircle(
      Offset(size.width * 2 / 3, size.height * 3 / 4),
      dotRadius,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DominoIcon extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color dotColor;

  const DominoIcon({
    super.key,
    this.size = 200,
    this.backgroundColor = Colors.white,
    this.dotColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.5, // Domino is taller than it is wide
      child: CustomPaint(
        painter: DominoIconPainter(
          backgroundColor: backgroundColor,
          dotColor: dotColor,
        ),
      ),
    );
  }
}
