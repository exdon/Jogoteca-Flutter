import 'package:flutter/material.dart';
import 'dart:math' as math;

class ClinkingGlassesEffect extends StatefulWidget {
  const ClinkingGlassesEffect({
    super.key,
    this.size = 64,
    this.colorLeft,
    this.colorRight,
    this.icon = Icons.sports_bar,
    this.duration = const Duration(milliseconds: 1600),
    this.loop = true,
    this.tiltAngle = 14, // graus
    this.separationFactor = 2.6,
    this.sparkColor,
    this.showSparks = true,
    this.backgroundSizeFactor = 4.0,
    this.minTouchGapFactor = 0.4,
    this.overlapFactor = 0.0,
    this.onClink,
  });

  final double size;
  final Color? colorLeft;
  final Color? colorRight;
  final IconData icon;
  final Duration duration;
  final bool loop;
  final double tiltAngle;
  final double separationFactor;
  final Color? sparkColor;
  final bool showSparks;
  final double backgroundSizeFactor;

  /// Fator da largura mínima entre centros para "encostar" sem cruzar (0.5 = metade do size)
  final double minTouchGapFactor;

  /// Quanto avançam um sobre o outro no pico (0.0 = nenhum avanço)
  final double overlapFactor;

  final VoidCallback? onClink;

  @override
  State<ClinkingGlassesEffect> createState() => _ClinkingGlassesEffectState();
}

class _ClinkingGlassesEffectState extends State<ClinkingGlassesEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _approach;
  late final Animation<double> _clink;
  late final Animation<double> _recoil;

  bool _clinkedThisCycle = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _approach = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.45, curve: Curves.easeInOut),
    );

    _clink = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 45,
      ),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.45, 0.62)),
    );

    _recoil = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.62, 0.80, curve: Curves.easeOut),
    );

    _controller.addListener(_handleClinkCallback);

    widget.loop ? _controller.repeat() : _controller.forward();
  }

  void _handleClinkCallback() {
    if (!_clinkedThisCycle &&
        _controller.value >= 0.54 &&
        _controller.value <= 0.58) {
      _clinkedThisCycle = true;
      widget.onClink?.call();
    }
    if (_controller.value < 0.1) {
      _clinkedThisCycle = false;
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_handleClinkCallback)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.colorLeft ?? Theme.of(context).colorScheme.primary;
    final secondary =
        widget.colorRight ?? Theme.of(context).colorScheme.secondary;
    final sparkColor =
        widget.sparkColor ?? Color.lerp(primary, secondary, 0.5) ?? Colors.amber;

    final tiltRad = (widget.tiltAngle) * math.pi / 180.0;
    final baseSep = widget.size * widget.separationFactor;

    final boxSize = widget.size * widget.backgroundSizeFactor;

    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final approachT = _approach.value;
          final clinkT = _clink.value;
          final recoilT = _recoil.value;

          final approachX = baseSep * (1 - approachT);
          final recoilX = baseSep * 0.25 * recoilT;

          final extraOverlap =
              widget.size * widget.overlapFactor * clinkT; // configurável

          // folga mínima para encostar sem cruzar
          final minGap = widget.size * widget.minTouchGapFactor;

          // compensação pela inclinação
          final angleComp = math.sin(tiltRad) * (widget.size * 0.5);

          final dist =
              ((approachX + recoilX) * 0.5) - extraOverlap;

          final currentX = math.max(minGap + angleComp, dist);

          final tiltBoost = tiltRad * (0.5 + 0.5 * clinkT);
          final leftTilt = -(tiltRad * approachT + tiltBoost * 0.25);
          final rightTilt = (tiltRad * approachT + tiltBoost * 0.25);

          final clinkScale = 1.0 + 0.08 * clinkT;

          final double sparkOpacity = widget.showSparks
              ? math.min(1.0, math.max(0.0, clinkT))
              : 0.0;
          final sparkScale = 0.6 + 0.8 * clinkT;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (sparkOpacity > 0)
                Transform.scale(
                  scale: sparkScale,
                  child: Opacity(
                    opacity: sparkOpacity,
                    child: _ClinkSparks(
                      color: sparkColor,
                      strokeWidth: widget.size * 0.08,
                    ),
                  ),
                ),
              // Copo esquerdo espelhado
              Transform.translate(
                offset: Offset(-currentX, 0),
                child: Transform.rotate(
                  angle: leftTilt,
                  child: Transform.scale(
                    scale: clinkScale,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: Icon(widget.icon, size: widget.size, color: primary),
                    ),
                  ),
                ),
              ),
              // Copo direito normal
              Transform.translate(
                offset: Offset(currentX, 0),
                child: Transform.rotate(
                  angle: rightTilt,
                  child: Transform.scale(
                    scale: clinkScale,
                    child:
                    Icon(widget.icon, size: widget.size, color: secondary),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ClinkSparks extends StatelessWidget {
  const _ClinkSparks({required this.color, this.strokeWidth = 3});
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparksPainter(color: color, strokeWidth: strokeWidth),
      size: const Size(60, 60),
    );
  }
}

class _SparksPainter extends CustomPainter {
  _SparksPainter({required this.color, required this.strokeWidth});
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.26;

    for (int i = 0; i < 6; i++) {
      final angle = (math.pi * 2 / 6) * i;
      final dir = Offset(math.cos(angle), math.sin(angle));
      final p1 = center + dir * (radius * 0.35);
      final p2 = center + dir * radius;
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparksPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
