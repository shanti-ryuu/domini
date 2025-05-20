import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:domini/widgets/domino_icon_painter.dart';

class IconGenerator {
  static Future<void> generateAppIcon() async {
    final RenderRepaintBoundary boundary = RenderRepaintBoundary();
    final RenderView renderView = RenderView(
      window: ui.window,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: boundary,
      ),
      configuration: ViewConfiguration(
        size: const Size(1024, 1024),
        devicePixelRatio: 1.0,
      ),
    );

    final DominoIconPainter painter = DominoIconPainter(
      backgroundColor: Colors.white,
      dotColor: const Color(0xFF007AFF),
    );

    final RenderCustomPaint renderCustomPaint = RenderCustomPaint(
      painter: painter,
      size: const Size(1024, 1024),
    );

    boundary.child = renderCustomPaint;
    renderView.compositeFrame();

    final ui.Image image = await boundary.toImage(1024);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final File file = File('assets/icons/app_icon.png');
    await file.writeAsBytes(pngBytes);

    // Create splash icon (slightly larger)
    final File splashFile = File('assets/icons/splash_icon.png');
    await splashFile.writeAsBytes(pngBytes);
  }
}
