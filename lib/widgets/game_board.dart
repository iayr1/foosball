import 'dart:math';

import 'package:flutter/material.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Colors.black87, blurRadius: 24, offset: Offset(0, 14)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            const Positioned.fill(child: _WoodBoard()),
            ..._buildPucks(isTop: true),
            ..._buildPucks(isTop: false),
            const _DirectionHints(),
            const _AimingLine(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPucks({required bool isTop}) {
    final points = isTop
        ? const [Offset(0.18, 0.18), Offset(0.35, 0.18), Offset(0.52, 0.2), Offset(0.68, 0.16), Offset(0.82, 0.2)]
        : const [Offset(0.2, 0.82), Offset(0.36, 0.77), Offset(0.52, 0.84), Offset(0.68, 0.79), Offset(0.82, 0.84)];

    return points
        .map(
          (p) => Positioned.fill(
            child: Align(
              alignment: Alignment(p.dx * 2 - 1, p.dy * 2 - 1),
              child: _Puck(isWhite: !isTop),
            ),
          ),
        )
        .toList();
  }
}

class _WoodBoard extends StatelessWidget {
  const _WoodBoard();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WoodPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _WoodPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD8A36A), Color(0xFFC88D52), Color(0xFFB7763E)],
        ).createShader(rect),
    );

    final grain = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1.3;
    for (var i = 0; i < 22; i++) {
      final y = i * (size.height / 20);
      final wave = sin(i * 0.7) * 8;
      canvas.drawLine(Offset(0, y + wave), Offset(size.width, y - wave), grain);
    }

    final yMid = size.height / 2;
    final gap = size.width * 0.12;
    final wallPaint = Paint()
      ..color = const Color(0xFF6B4322)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(20, yMid), Offset(size.width / 2 - gap, yMid), wallPaint);
    canvas.drawLine(Offset(size.width / 2 + gap, yMid), Offset(size.width - 20, yMid), wallPaint);

    final glowRect = Rect.fromCircle(center: Offset(size.width / 2, yMid), radius: 40);
    canvas.drawCircle(
      Offset(size.width / 2, yMid),
      40,
      Paint()..shader = const RadialGradient(colors: [Color(0x66F9DF7A), Colors.transparent]).createShader(glowRect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, Colors.black.withOpacity(0.38)],
          stops: const [0.72, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Puck extends StatelessWidget {
  const _Puck({required this.isWhite});

  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    final base = isWhite ? const Color(0xFFF3F3F3) : const Color(0xFF181818);
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withOpacity(0.25), base],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
    );
  }
}

class _DirectionHints extends StatelessWidget {
  const _DirectionHints();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.keyboard_arrow_down, color: Color(0xAAFFFFFF), size: 28),
            SizedBox(height: 32),
            Icon(Icons.keyboard_arrow_up, color: Color(0xAAFFFFFF), size: 28),
          ],
        ),
      ),
    );
  }
}

class _AimingLine extends StatelessWidget {
  const _AimingLine();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Column(
        children: [
          SizedBox(
            width: 3,
            height: 72,
            child: CustomPaint(painter: _DottedLinePainter()),
          ),
          const Icon(Icons.arrow_upward_rounded, color: Colors.white70, size: 18),
        ],
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = size.width
      ..strokeCap = StrokeCap.round;

    const dot = 5.0;
    const gap = 6.0;
    double y = size.height;
    while (y > 0) {
      canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, y - dot), paint);
      y -= dot + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
