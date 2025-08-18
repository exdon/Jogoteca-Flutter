import 'dart:math';

import 'package:flutter/material.dart';

class ConfettiEffect extends StatefulWidget {
  const ConfettiEffect({super.key});

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _confettiSpread;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _confettiSpread = Tween<double>(begin: 0, end: 40).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildConfetti(double angle, Color color) {
    return Transform.translate(
      offset: Offset(
        _confettiSpread.value * cos(angle),
        -_confettiSpread.value * sin(angle),
      ),
      child: Icon(Icons.circle, color: color, size: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _confettiSpread,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.celebration, color: Colors.orange, size: 40),
            buildConfetti(0.2, Colors.pink),
            buildConfetti(0.8, Colors.blue),
            buildConfetti(1.5, Colors.green),
            buildConfetti(2.2, Colors.yellow),
            buildConfetti(2.8, Colors.purple),
          ],
        );
      },
    );
  }
}
