import 'package:flutter/material.dart';

class AnimatedLetter extends StatefulWidget {
  final String letra;
  final Duration delay;

  const AnimatedLetter({super.key, required this.letra, required this.delay});

  @override
  State<AnimatedLetter> createState() => _AnimatedLetterState();
}

class _AnimatedLetterState extends State<AnimatedLetter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Text(
        widget.letra,
        style: const TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 4,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
