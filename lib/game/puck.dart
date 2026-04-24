import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../models/game_mode.dart';

class Puck extends PositionComponent with DragCallbacks, CollisionCallbacks {
  static const double radius = 16;

  final String ownerId;
  final Color puckColor;
  final GameController controller;
  final bool isHuman;
  final double midLineY;
  final bool Function(Puck puck) canShoot;
  final bool Function(Vector2 position) isHumanArea;
  final bool Function(Vector2 position) isAIArea;

  Vector2 velocity = Vector2.zero();
  Vector2 _dragVector = Vector2.zero();
  Vector2? _dragPointerBoardPosition;
  bool _isDragging = false;

  Vector2 get _puckCenterOffset => Vector2.all(radius);

  // Tunable per-puck physics values used by the PhysicsEngine.
  final double frictionPerSecond = 0.985;
  final double maxVelocity = 980;

  Puck({
    required this.ownerId,
    required this.puckColor,
    required this.controller,
    required this.isHuman,
    required this.midLineY,
    required this.canShoot,
    required this.isHumanArea,
    required this.isAIArea,
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
    super.onDragStart(event);
    if (!controller.canControlPlayer(ownerId)) return;
    if (isMoving) return;
    if (controller.mode == GameMode.vsAI) {
      if (!isHuman) return;
      if (!isHumanArea(position)) return;
    } else {
      if (controller.turn == GameTurn.human && !isHumanArea(position)) return;
      if (controller.turn == GameTurn.player2 && !isAIArea(position)) return;
    }

    _isDragging = true;
    _dragVector = Vector2.zero();
    _dragPointerBoardPosition =
        position + event.localPosition - _puckCenterOffset;
    event.continuePropagation = false;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_isDragging) return;

    final previousPointer = _dragPointerBoardPosition ?? position.clone();
    final currentPointer = previousPointer + event.localDelta;

    // Clamp drag pointer to human territory so aim input never crosses midline.
    if (controller.mode == GameMode.vsAI && isHuman && currentPointer.y < midLineY) {
      currentPointer.y = midLineY;
    }
    if (controller.mode == GameMode.twoPlayer) {
      if (controller.turn == GameTurn.human && currentPointer.y < midLineY) {
        currentPointer.y = midLineY;
      }
      if (controller.turn == GameTurn.player2 && currentPointer.y > midLineY) {
        currentPointer.y = midLineY;
      }
    }

    // Pull opposite to swipe direction to create slingshot behavior.
    _dragVector -= (currentPointer - previousPointer);
    if (_dragVector.length > 140) {
      _dragVector.scaleTo(140);
    }

    _dragPointerBoardPosition = currentPointer;
    event.continuePropagation = false;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!_isDragging) return;

    const double releasePower = 8.5;
    if (canShoot(this)) {
      applyShotVelocity(_dragVector * releasePower);
      controller.registerHumanShot();
    }
    _isDragging = false;
    _dragVector = Vector2.zero();
    _dragPointerBoardPosition = null;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _isDragging = false;
    _dragVector = Vector2.zero();
    _dragPointerBoardPosition = null;
  }

  void applyShotVelocity(Vector2 shotVelocity) {
    velocity += shotVelocity;
    if (velocity.length > maxVelocity) {
      velocity.scaleTo(maxVelocity);
    }
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
