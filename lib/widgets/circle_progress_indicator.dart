import 'package:flutter/material.dart';

/// A widget that draws and animates a circular progress ring with center text.
class CircleProgressWidget extends StatefulWidget {
  /// Fraction of the ring to fill: 0.0 = empty, 1.0 = full.
  final double progress;
  /// Diameter of the circle.
  final double size;
  /// Width of the ring.
  final double strokeWidth;
  /// Color of the unfilled ring.
  final Color backgroundColor;
  /// Color of the filled portion.
  final Color progressColor;
  /// Text to display in the center
  final String label;

  const CircleProgressWidget({
    Key? key,
    required this.progress,
    required this.size,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
    required this.label,
  }) : super(key: key);

  @override
  CircleProgressWidgetState createState() => CircleProgressWidgetState();
}

class CircleProgressWidgetState extends State<CircleProgressWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    )..addListener(() => setState(() {}));
    controller.forward();
  }

  @override
  void didUpdateWidget(covariant CircleProgressWidget old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      animation = Tween<double>(
        begin: animation.value,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
      controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Draw the ring
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _CirclePainter(
              progress: animation.value,
              strokeWidth: widget.strokeWidth,
              bgColor: widget.backgroundColor,
              fgColor: widget.progressColor,
            ),
          ),
          // Center label
          Text(
            widget.label,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color bgColor;
  final Color fgColor;

  _CirclePainter({
    required this.progress,
    required this.strokeWidth,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pi = 3.1416;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background ring
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw progress arc
    final fgPaint = Paint()
      ..color = fgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // start at top
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter old) =>
      old.progress != progress;
}
