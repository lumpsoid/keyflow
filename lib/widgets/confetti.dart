import 'dart:math';

import 'package:flutter/material.dart';

/// A one-off burst of confetti from the top of its area.
class Confetti extends StatefulWidget {
  const Confetti({super.key, required this.colors});

  final List<Color> colors;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  static const _count = 90;

  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  late final List<_Piece> _pieces = () {
    final random = Random();
    return [
      for (var i = 0; i < _count; i++)
        _Piece(
          x: 0.5 + (random.nextDouble() - 0.5) * 0.3,
          vx: (random.nextDouble() - 0.5) * 1.4,
          vy: -0.6 - random.nextDouble() * 0.9,
          spin: (random.nextDouble() - 0.5) * 18,
          size: 5 + random.nextDouble() * 6,
          color: widget.colors[i % widget.colors.length],
        ),
    ];
  }();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect "remove animations" accessibility settings.
    if (MediaQuery.disableAnimationsOf(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(_pieces, _controller),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.vx,
    required this.vy,
    required this.spin,
    required this.size,
    required this.color,
  });

  /// Start, as a fraction of the width.
  final double x;

  /// Velocities in heights per second.
  final double vx;
  final double vy;
  final double spin;
  final double size;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.animation) : super(repaint: animation);

  static const _gravity = 1.6;

  final List<_Piece> pieces;
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value * 2.6;
    final fade = (1 - animation.value * animation.value).clamp(0.0, 1.0);
    final paint = Paint();
    for (final p in pieces) {
      final x = size.width * p.x + p.vx * t * size.height * 0.5;
      final y =
          size.height * 0.25 +
          (p.vy * t + _gravity * t * t / 2) * size.height * 0.5;
      paint.color = p.color.withValues(alpha: fade);
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(p.spin * t)
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.55,
          ),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}
