import 'dart:math';

import 'package:flutter/material.dart';

/// Running wpm over the round, drawn in as it appears.
class WpmChart extends StatelessWidget {
  const WpmChart({super.key, required this.samples});

  final List<double> samples;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: scheme.onSurfaceVariant);
    if (samples.length < 2) return const SizedBox.shrink();
    final top = (samples.reduce(max) / 20).ceil() * 20.0;
    return Semantics(
      label: 'wpm over time chart',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(top.toStringAsFixed(0), style: labelStyle),
              Text('0', style: labelStyle),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, progress, _) => CustomPaint(
                painter: _ChartPainter(
                  samples: samples,
                  top: max(top, 1),
                  progress: progress,
                  line: scheme.primary,
                  grid: scheme.surfaceContainerHigh,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.samples,
    required this.top,
    required this.progress,
    required this.line,
    required this.grid,
  });

  final List<double> samples;
  final double top;
  final double progress;
  final Color line;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    Offset at(int i) => Offset(
      size.width * i / (samples.length - 1),
      size.height * (1 - samples[i] / top),
    );
    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < samples.length; i++) {
      final a = at(i - 1), b = at(i);
      final midX = (a.dx + b.dx) / 2;
      path.cubicTo(midX, a.dy, midX, b.dy, b.dx, b.dy);
    }

    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, -4, size.width * progress, size.height + 8),
    );
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [line.withValues(alpha: 0.28), line.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.progress != progress || old.samples != samples || old.line != line;
}
