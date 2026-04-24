import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Wall extends PositionComponent {
  final Vector2 wallSize;

  Wall({required Vector2 position, required this.wallSize})
      : super(position: position, size: wallSize, anchor: Anchor.topLeft);

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF70461F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(6)),
      paint,
    );

    final shadowPaint = Paint()..color = const Color(0x22000000);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, size.x - 4, size.y - 4),
        const Radius.circular(5),
      ),
      shadowPaint,
    );
  }
}
