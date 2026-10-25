import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

class GolfHeading extends StatelessWidget {
  const GolfHeading({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.hole,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final String hole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TU RECORRIDO / $hole',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(title, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 27,
            ),
          ),
        ],
      ),
    );
  }
}

/// Anima el cambio de pestaña sin recrear el contenido ni perder sus registros.
class GolfEntrance extends StatefulWidget {
  const GolfEntrance({super.key, required this.child, required this.page});
  final Widget child;
  final int page;
  @override
  State<GolfEntrance> createState() => _GolfEntranceState();
}

class _GolfEntranceState extends State<GolfEntrance>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(GolfEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page &&
        !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (_, child) {
        final value = Curves.easeOutCubic.transform(_controller.value);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}

/// Campo y pelota dibujados con Flutter, sin imágenes ni paquetes adicionales.
class FairwayScene extends StatefulWidget {
  const FairwayScene({super.key});
  @override
  State<FairwayScene> createState() => _FairwaySceneState();
}

class _FairwaySceneState extends State<FairwayScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0.65;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => CustomPaint(
        painter: _FairwayPainter(_controller.value),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _FairwayPainter extends CustomPainter {
  _FairwayPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 320, size.height / 200);
    final paint = Paint();
    canvas.drawOval(
      const Rect.fromLTWH(8, 26, 305, 162),
      paint..color = const Color(0xFF226849),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(const Rect.fromLTWH(8, 26, 305, 162)));
    for (var i = -4; i < 12; i++) {
      canvas.drawLine(
        Offset(i * 37, 0),
        Offset(i * 37 + 100, 210),
        Paint()
          ..color = const Color(0xFF2B7550)
          ..strokeWidth = 18,
      );
    }
    canvas.restore();
    canvas.drawOval(
      const Rect.fromLTWH(165, 42, 117, 77),
      paint..color = const Color(0xFF9DBE72),
    );
    canvas.drawOval(
      const Rect.fromLTWH(55, 126, 67, 29),
      paint..color = const Color(0xFFE6D5A7),
    );
    canvas.drawOval(
      const Rect.fromLTWH(232, 84, 13, 5),
      paint..color = const Color(0xFF153F2C),
    );
    canvas.drawLine(
      const Offset(238, 86),
      const Offset(238, 14),
      Paint()
        ..color = const Color(0xFFFAFBF6)
        ..strokeWidth = 2.5,
    );
    final flutter = math.sin(progress * math.pi * 2) * 3;
    canvas.drawPath(
      Path()
        ..moveTo(239, 14)
        ..lineTo(270, 22 + flutter)
        ..lineTo(239, 34)
        ..close(),
      paint..color = golfLime,
    );
    final trail = Path()
      ..moveTo(86, 174)
      ..quadraticBezierTo(130, 55, 238, 87);
    final metric = trail.computeMetrics().first;
    for (double d = 0; d < metric.length; d += 12) {
      canvas.drawCircle(
        metric.getTangentForOffset(d)!.position,
        1.6,
        paint..color = Colors.white.withValues(alpha: 0.28),
      );
    }
    final t = Curves.easeInOutCubic.transform((progress / 0.8).clamp(0.0, 1.0));
    final ball = metric.getTangentForOffset(metric.length * t)!.position;
    canvas.drawOval(
      Rect.fromCenter(center: ball + const Offset(1, 5), width: 13, height: 5),
      paint..color = Colors.black.withValues(alpha: 0.2),
    );
    canvas.drawCircle(ball, 6, paint..color = Colors.white);
    canvas.drawCircle(
      ball + const Offset(-1, 2),
      1,
      paint..color = const Color(0xFFD9E2D6),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FairwayPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
