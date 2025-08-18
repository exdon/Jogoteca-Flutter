import 'package:flutter/material.dart';

class BrokenHeartEffect extends StatefulWidget {
  const BrokenHeartEffect({super.key});

  @override
  State<BrokenHeartEffect> createState() => _BrokenHeartEffectState();
}

class _BrokenHeartEffectState extends State<BrokenHeartEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? _offset; // Agora é nullable

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _offset = Tween<double>(begin: 0, end: 30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildHalf({required bool isLeft}) {
    if (_offset == null) return const SizedBox(); // Proteção extra

    return AnimatedBuilder(
      animation: _offset!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(isLeft ? -_offset!.value : _offset!.value, 0),
          child: ClipRect(
            clipper: _HalfClipper(isLeft: isLeft),
            child: const Icon(Icons.heart_broken, color: Colors.red, size: 60),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        buildHalf(isLeft: true),
        buildHalf(isLeft: false),
      ],
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  final bool isLeft;

  _HalfClipper({required this.isLeft});

  @override
  Rect getClip(Size size) {
    return isLeft
        ? Rect.fromLTWH(0, 0, size.width / 2, size.height)
        : Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
