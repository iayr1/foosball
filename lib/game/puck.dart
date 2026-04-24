import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';

class Puck extends PositionComponent with DragCallbacks, CollisionCallbacks {
  static const double radius = 16;

  final String ownerId;
  final Color puckColor;
  final GameController controller;

  Vector2 velocity = Vector2.zero();
  Vector2 _dragVector = Vector2.zero();
  bool _isDragging = false;

  Puck({
    required this.ownerId,
    required this.puckColor,
    required this.controller,
    required Vector2 initialPosition,
  }) : super(
          position: initialPosition,
          size: Vector2.all(radius * 2),
          anchor: Anchor.center,
          priority: 20,
        );

  bool get isMoving => velocity.length2 > 25;

  @override
  Future<void> onLoad() async {
    await add(CircleHitbox());
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (!controller.canControlPlayer(ownerId)) return;
    if (isMoving) return;

    _isDragging = true;
    _dragVector = Vector2.zero();
    event.continuePropagation = false;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_isDragging) return;

    // Pull opposite to swipe direction to create slingshot behavior.
    _dragVector -= event.localDelta;
    if (_dragVector.length > 140) {
      _dragVector.scaleTo(140);
    }
    event.continuePropagation = false;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (!_isDragging) return;

    const double releasePower = 8.5;
    velocity += _dragVector * releasePower;
    _isDragging = false;
    _dragVector = Vector2.zero();
    controller.switchTurn();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _isDragging = false;
    _dragVector = Vector2.zero();
  }

  @override
  void render(Canvas canvas) {
    final puckPaint = Paint()..color = puckColor;
    final shadow = Paint()..color = const Color(0x33000000);

    canvas.drawCircle(
      Offset(radius + 3, radius + 3),
      radius,
      shadow,
    );
    canvas.drawCircle(Offset(radius, radius), radius, puckPaint);

    final gloss = Paint()..color = const Color(0x22FFFFFF);
    canvas.drawCircle(Offset(radius - 5, radius - 5), radius * 0.35, gloss);

    if (_isDragging) {
      final aim = Paint()
        ..color = const Color(0x99FFFFFF)
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(radius, radius),
        Offset(radius + _dragVector.x * 0.5, radius + _dragVector.y * 0.5),
        aim,
      );
    }
  }
}
