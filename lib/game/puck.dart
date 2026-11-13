import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../audio/sfx_service.dart';
import '../controllers/game_controller.dart';
import '../data/catalog.dart';
import '../models/game_mode.dart';
import '../widgets/glossy.dart' show PuckPainter;

class Puck extends PositionComponent with DragCallbacks, CollisionCallbacks {
  static const double radius = 16;
  static const double maxPull = 140;

  final String ownerId;
  final PuckSkin skin;
  final GameController controller;
  final bool isHuman;
  final double midLineY;
  final bool Function(Puck puck) canShoot;
  final bool Function(Vector2 position) isHumanArea;
  final bool Function(Vector2 position) isAIArea;
  final bool Function() showAimGuide;
  final void Function(double? power)? onAim;

  Vector2 velocity = Vector2.zero();
  Vector2 _dragVector = Vector2.zero();
  Vector2? _dragPointerBoardPosition;
  bool _isDragging = false;
  double _pulse = 0;

  Vector2 get _puckCenterOffset => Vector2.all(radius);

  final double frictionPerSecond = 0.985;
  final double maxVelocity = 980;

  Puck({
    required this.ownerId,
    required this.skin,
    required this.controller,
    required this.isHuman,
    required this.midLineY,
    required this.canShoot,
    required this.isHumanArea,
    required this.isAIArea,
    required this.showAimGuide,
    this.onAim,
    required Vector2 initialPosition,
  }) : super(position: initialPosition, size: Vector2.all(radius * 2), anchor: Anchor.center, priority: 20);

  bool get isMoving => velocity.length2 > 25;

  /// True when it is this puck owner's turn and the puck may be flicked now.
  bool get isPlayable {
    if (!controller.canControlPlayer(ownerId) || isMoving) return false;
    if (controller.mode == GameMode.vsAI) return isHuman && isHumanArea(position);
    if (controller.turn == GameTurn.human) return isHumanArea(position);
    if (controller.turn == GameTurn.player2) return isAIArea(position);
    return false;
  }

  @override
  Future<void> onLoad() async {
    await add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulse = (_pulse + dt * 3) % (math.pi * 2);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!isPlayable) return;

    _isDragging = true;
    _dragVector = Vector2.zero();
    _dragPointerBoardPosition = position + event.localPosition - _puckCenterOffset;
    SfxService.instance.playSlingStretch();
    onAim?.call(0);
    event.continuePropagation = false;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_isDragging) return;

    final previousPointer = _dragPointerBoardPosition ?? position.clone();
    final currentPointer = previousPointer + event.localDelta;

    final bottomShooter = controller.mode == GameMode.vsAI || controller.turn == GameTurn.human;
    if (bottomShooter && currentPointer.y < midLineY) currentPointer.y = midLineY;
    if (!bottomShooter && currentPointer.y > midLineY) currentPointer.y = midLineY;

    // Pull opposite to swipe direction to create slingshot behaviour.
    _dragVector -= (currentPointer - previousPointer);
    if (_dragVector.length > maxPull) _dragVector.scaleTo(maxPull);

    _dragPointerBoardPosition = currentPointer;
    onAim?.call(_dragVector.length / maxPull);
    event.continuePropagation = false;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!_isDragging) return;

    const double releasePower = 8.5;
    if (_dragVector.length > 6 && canShoot(this)) {
      applyShotVelocity(_dragVector * releasePower);
      controller.registerHumanShot();
    }
    _endDrag();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _endDrag();
  }

  void _endDrag() {
    _isDragging = false;
    _dragVector = Vector2.zero();
    _dragPointerBoardPosition = null;
    onAim?.call(null);
  }

  void applyShotVelocity(Vector2 shotVelocity) {
    velocity += shotVelocity;
    if (velocity.length > maxVelocity) velocity.scaleTo(maxVelocity);
    SfxService.instance.playStriker();
  }

  @override
  void render(Canvas canvas) {
    const c = Offset(radius, radius);

    // Soft "your turn" halo on pucks the player can flick.
    if (!_isDragging && isPlayable) {
      final a = 0.25 + 0.2 * math.sin(_pulse);
      canvas.drawCircle(c, radius + 5, Paint()..color = Colors.white.withValues(alpha: a));
    }

    if (_isDragging) {
      final power = _dragVector.length / maxPull;
      final shot = _dragVector * 0.5;

      // Elastic pulled back from the puck towards the finger.
      final pull = Offset(-shot.x * 0.6, -shot.y * 0.6);
      canvas.drawLine(
        c,
        c + pull,
        Paint()
          ..color = const Color(0xFF22262F)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );

      if (showAimGuide() && _dragVector.length > 4) {
        final dir = _dragVector.normalized();
        final len = 60 + power * 260;
        final dot = Paint()..color = Colors.white.withValues(alpha: 0.9);
        for (double d = radius + 10; d < len; d += 16) {
          final fade = 1 - d / (len + 20);
          dot.color = Colors.white.withValues(alpha: 0.9 * fade);
          canvas.drawCircle(c + Offset(dir.x * d, dir.y * d), 3, dot);
        }
      }

      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Color.lerp(const Color(0xFFFFE08A), const Color(0xFFFF4B3A), power)!;
      canvas.drawArc(Rect.fromCircle(center: c, radius: radius + 7), -math.pi / 2, math.pi * 2 * power, false, ring);
    }

    PuckPainter.paintPuck(canvas, c, radius, skin);
  }
}
