import 'package:flutter/material.dart';

class ClappingHands extends StatefulWidget {
  const ClappingHands({super.key});

  @override
  State<ClappingHands> createState() => _ClappingHandsState();
}

class _ClappingHandsState extends State<ClappingHands>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -20, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(_animation.value, 0),
              child: Transform.rotate(
                angle: -0.5,
                child: const Icon(Icons.pan_tool, color: Colors.white, size: 40),
              ),
            ),
            // 🌟 Faísca entre as mãos
            if (_animation.value > -1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.star, color: Colors.yellow, size: 20),
              ),
            const SizedBox(width: 10),
            Transform.translate(
              offset: Offset(-_animation.value, 0),
              child: Transform.rotate(
                angle: 0.5,
                child: const Icon(Icons.pan_tool, color: Colors.white, size: 40),
              ),
            ),
          ],
        );
      },
    );
  }
}

