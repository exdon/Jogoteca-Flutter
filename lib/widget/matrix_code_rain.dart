import 'dart:math';
import 'package:flutter/material.dart';

class MatrixCodeRain extends CustomPainter {
  final Random _rand = Random();
  final List<String> _chars =
  "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz@#\$%&*+-/".split('');

  @override
  void paint(Canvas canvas, Size size) {
    final columnCount = (size.width / 16).floor();

    for (int i = 0; i < columnCount; i++) {
      double x = i * 16;
      double yStart = _rand.nextDouble() * size.height;
      int trailLength = 6 + _rand.nextInt(8);

      for (int j = 0; j < trailLength; j++) {
        double y = (yStart + j * 20) % size.height;
        final opacity = 1.0 - (j / trailLength);
        final textStyle = TextStyle(
          color: j == 0
              ? Colors.white.withOpacity(opacity)
              : Colors.greenAccent.withOpacity(opacity),
          fontSize: 16,
          fontFamily: 'monospace',
        );

        final text = TextSpan(
          text: _chars[_rand.nextInt(_chars.length)],
          style: textStyle,
        );

        final tp = TextPainter(
          text: text,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
