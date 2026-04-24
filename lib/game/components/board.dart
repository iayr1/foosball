import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../foosball_game.dart';

class BoardComponent extends PositionComponent {
  BoardComponent()
    : super(
        size: Vector2(FoosballGame.boardWidth, FoosballGame.boardHeight),
        anchor: Anchor.center,
      );

  @override
  void render(Canvas canvas) {
    // Wood Texture (Gradient for depth)
    final rect = size.toRect();
    final woodGradient = LinearGradient(
      colors: [Color(0xFF8B5A2B), Color(0xFF6F4320)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);

    final woodPaint = Paint()..shader = woodGradient;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(20)),
      woodPaint,
    );

    // Border
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(20)),
      borderPaint,
    );

    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..strokeWidth = 5;

    final midX = size.x / 2;
    final midY = size.y / 2;
    final gateHalfWidth = FoosballGame.gateWidth / 2;

    // Horizonal Divider Lines
    canvas.drawLine(
      Offset(0, midY),
      Offset(midX - gateHalfWidth, midY),
      linePaint,
    );
    canvas.drawLine(
      Offset(midX + gateHalfWidth, midY),
      Offset(size.x, midY),
      linePaint,
    );

    // Gate Decor
    final trianglePaint = Paint()..color = Colors.black.withValues(alpha: 0.8);

    // Left Triangle
    final leftTri = Path()
      ..moveTo(midX - gateHalfWidth, midY)
      ..lineTo(midX - gateHalfWidth - 30, midY - 40)
      ..lineTo(midX - gateHalfWidth - 30, midY + 40)
      ..close();
    canvas.drawPath(leftTri, trianglePaint);

    // Right Triangle
    final rightTri = Path()
      ..moveTo(midX + gateHalfWidth, midY)
      ..lineTo(midX + gateHalfWidth + 30, midY - 40)
      ..lineTo(midX + gateHalfWidth + 30, midY + 40)
      ..close();
    canvas.drawPath(rightTri, trianglePaint);

    // Glow effect for center
    canvas.drawCircle(
      Offset(midX, midY),
      15,
      Paint()
        ..color = Colors.amber.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(Offset(midX, midY), 5, Paint()..color = Colors.black);
  }
}
