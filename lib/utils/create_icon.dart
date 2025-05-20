import 'package:flutter/material.dart';
import 'package:domini/widgets/domino_icon_painter.dart';

void main() async {
  // This is a simple script to create an app icon
  // Run this with: flutter run -d chrome lib/utils/create_icon.dart
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: RepaintBoundary(
            key: GlobalKey(),
            child: Container(
              width: 512,
              height: 512,
              color: Colors.white,
              child: const DominoIcon(
                size: 400,
                backgroundColor: Color(0xFF007AFF),
                dotColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
