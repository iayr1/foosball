import 'dart:math';

import 'package:flutter/material.dart';

class GameBoardWidget extends StatelessWidget {
  const GameBoardWidget({
    super.key,
    this.highlightGap = true,
    this.gameLayer,
  });

  final bool highlightGap;

  /// Optional interactive game renderer layered on top of the board art.
  final Widget? gameLayer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 30,
                spreadRadius: 3,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _WoodBoardPainter(highlightGap: highlightGap),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  if (gameLayer == null) ...[
                    ..._buildPucks(topSide: true),
                    ..._buildPucks(topSide: false),
                  ] else
                    Positioned.fill(child: gameLayer!),
                  const _HintArrows(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPucks({required bool topSide}) {
    final positions = topSide
        ? const [
            Offset(0.17, 0.18),
            Offset(0.33, 0.14),
            Offset(0.49, 0.22),
            Offset(0.63, 0.16),
            Offset(0.79, 0.21),
          ]
        : const [
            Offset(0.19, 0.79),
            Offset(0.35, 0.85),
            Offset(0.5, 0.76),
            Offset(0.66, 0.84),
            Offset(0.81, 0.78),
          ];

    return positions
        .map(
          (point) => Positioned.fill(
            child: Align(
              alignment: Alignment(point.dx * 2 - 1, point.dy * 2 - 1),
              child: _PuckChip(isPlayer: !topSide),
            ),
          ),
        )
        .toList();
  }
}

class _PuckChip extends StatelessWidget {
  const _PuckChip({required this.isPlayer});

  final bool isPlayer;

  @override
  Widget build(BuildContext context) {
    final baseColor = isPlayer ? const Color(0xFFEFEFEF) : const Color(0xFF191A1C);

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(Colors.white.withOpacity(0.22), baseColor),
            baseColor,
          ],
        ),
        border: Border.all(
          color: isPlayer ? Colors.white.withOpacity(0.5) : Colors.black,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
}

class _HintArrows extends StatelessWidget {
  const _HintArrows();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xA6FF9F43), size: 26),
            SizedBox(height: 28),
            Icon(Icons.keyboard_arrow_up_rounded,
                color: Color(0xA6FF9F43), size: 26),
          ],
        ),
      ),
    );
  }
}

class _WoodBoardPainter extends CustomPainter {
  _WoodBoardPainter({required this.highlightGap});

  final bool highlightGap;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    final woodBase = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFD9A86C), Color(0xFFC88B4C), Color(0xFFBE7E42)],
      ).createShader(rect);
    canvas.drawRRect(rRect, woodBase);

    final grainPaint = Paint()
      ..color = const Color(0x44FFFFFF)
      ..strokeWidth = 1.4;
    for (var i = 0; i < 18; i++) {
      final y = size.height * (i / 18);
      final wave = sin(i * 0.9) * 7;
      canvas.drawLine(
        Offset(0, y + wave),
        Offset(size.width, y - wave),
        grainPaint,
      );
    }

    final dividerY = size.height * 0.5;
    final gapHalf = size.width * 0.1;
    final wallPaint = Paint()
      ..color = const Color(0xFF684019)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(18, dividerY),
      Offset(size.width / 2 - gapHalf, dividerY),
      wallPaint,
    );
    canvas.drawLine(
      Offset(size.width / 2 + gapHalf, dividerY),
      Offset(size.width - 18, dividerY),
      wallPaint,
    );

    if (highlightGap) {
      final glow = Paint()
        ..shader = RadialGradient(
          colors: [const Color(0x66FF9F43), Colors.transparent],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width / 2, dividerY),
            radius: 38,
          ),
        );
      canvas.drawCircle(Offset(size.width / 2, dividerY), 38, glow);
    }

    final innerShadow = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withOpacity(0.33)],
        stops: const [0.7, 1],
      ).createShader(rect);
    canvas.drawRRect(rRect, innerShadow);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.15);
    canvas.drawRRect(rRect, border);
  }

  @override
  bool shouldRepaint(covariant _WoodBoardPainter oldDelegate) {
    return highlightGap != oldDelegate.highlightGap;
  }
}
