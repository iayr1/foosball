import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Wall extends PositionComponent {
  final Vector2 wallSize;
  final Color color;
  final Color highlight;

  Wall({required Vector2 position, required this.wallSize, this.color = const Color(0xFF5A3218), this.highlight = const Color(0xFF7A4A28)})
    : super(position: position, size: wallSize, anchor: Anchor.topLeft, priority: 5);

  Rect get rect => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  @override
  void render(Canvas canvas) {
    final r = RRect.fromRectAndRadius(size.toRect(), const Radius.circular(4));
    canvas.drawRRect(r.shift(const Offset(0, 4)), Paint()..color = Colors.black.withValues(alpha: 0.35));
    canvas.drawRRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [highlight, color],
        ).createShader(size.toRect()),
    );
  }
}
