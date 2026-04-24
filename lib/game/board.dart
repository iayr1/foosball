import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Board extends PositionComponent {
  Board({required Vector2 boardSize}) : super(size: boardSize, anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    final wood = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFC5925A), Color(0xFF9A6739)],
      ).createShader(size.toRect());

    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(16)),
      wood,
    );

    final midLinePaint = Paint()
      ..color = const Color(0x66FFFFFF)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, size.y / 2), Offset(size.x, size.y / 2), midLinePaint);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = const Color(0xFF6E4325);
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(16)),
      border,
    );
  }
}
