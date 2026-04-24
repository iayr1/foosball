import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../foosball_game.dart';

class Puck extends PositionComponent
    with DragCallbacks, HasGameRef<FoosballGame> {
  final bool isPlayer1; // top = true, bottom = false
  Vector2 velocity = Vector2.zero();

  bool isDragging = false;
  Vector2? dragStart;
  Vector2? dragCurrent;

  final Paint _paint = Paint();
  final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final TextPaint _textPaint = TextPaint(
    style: const TextStyle(
      color: Colors.red,
      fontSize: 8,
      fontWeight: FontWeight.bold,
    ),
  );

  Puck({required this.isPlayer1, required Vector2 initialPosition})
    : super(
        position: initialPosition,
        size: Vector2.all(FoosballGame.puckRadius * 2),
        anchor: Anchor.center,
      ) {
    _paint.color = isPlayer1 ? Colors.black : Colors.white;
    _borderPaint.color = isPlayer1 ? Colors.grey : Colors.black;
  }

  @override
  void render(Canvas canvas) {
    // Glow/Shadow
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      width / 2 + 2,
      Paint()
        ..color = _paint.color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    canvas.drawCircle(Offset(width / 2, height / 2), width / 2, _paint);
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      width / 2 - 1,
      _borderPaint,
    );

    // "WINNER" Text centered
    _textPaint.render(
      canvas,
      'WINNER',
      Vector2(width / 2, height / 2),
      anchor: Anchor.center,
    );

    // Slingshot line
    if (isDragging && dragStart != null && dragCurrent != null) {
      final linePaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.8)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      final localCenter = size / 2;
      var dragDelta = dragCurrent! - dragStart!;
      if (dragDelta.length > 150) {
        dragDelta = dragDelta.normalized() * 150;
      }

      // Draw dashed line or gradient? Simple line for now.
      canvas.drawLine(
        Offset(localCenter.x, localCenter.y),
        Offset(localCenter.x + dragDelta.x, localCenter.y + dragDelta.y),
        linePaint,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (velocity.length > 0) {
      position += velocity * dt;
      velocity *= FoosballGame.friction;

      if (velocity.length < 5) {
        velocity = Vector2.zero();
      }

      final double r = width / 2;
      // Use world bounds if available, else hardcode board size relative to center
      // Board is 400x800 centered at (0,0) in our new Camera system?
      // Wait, in previous code board was at top-left 0,0?
      // In CameraComponent system, usually (0,0) is center if not offset.
      // But let's stick to positive coordinates 0..400, 0..800 for simplicity as setup in original.

      final leftLimit = r;
      final rightLimit = FoosballGame.boardWidth - r;
      final topLimit = r;
      final bottomLimit = FoosballGame.boardHeight - r;

      if (position.x <= leftLimit) {
        position.x = leftLimit;
        velocity.x = -velocity.x;
      } else if (position.x >= rightLimit) {
        position.x = rightLimit;
        velocity.x = -velocity.x;
      }

      if (position.y <= topLimit) {
        position.y = topLimit;
        velocity.y = -velocity.y;
      } else if (position.y >= bottomLimit) {
        position.y = bottomLimit;
        velocity.y = -velocity.y;
      }

      // gate / scoring logic
      final midY = FoosballGame.boardHeight / 2;
      final gateHalf = FoosballGame.gateWidth / 2;
      final midX = FoosballGame.boardWidth / 2;

      final inGateRange =
          (position.x > midX - gateHalf && position.x < midX + gateHalf);

      if (!inGateRange) {
        // wall divider logic
        if ((position.y - midY).abs() < r) {
          // Close to line
          // Check if crossing line?
          // Simple bounce if hitting the "barrier" zone (Y=midY)
          // Barrier is thin, but effectively a wall.

          // If coming from top (y < midY) and hitting midY - r
          if (position.y < midY && position.y + r >= midY) {
            position.y = midY - r - 1;
            velocity.y = -velocity.y * 0.8;
          }
          // If coming from bottom
          else if (position.y > midY && position.y - r <= midY) {
            position.y = midY + r + 1;
            velocity.y = -velocity.y * 0.8;
          }
        }
      } else {
        // passed through gate
        if (isPlayer1 && position.y > midY + height) {
          game.onGoalScored(true);
          removeFromParent();
          _respawn(true);
        } else if (!isPlayer1 && position.y < midY - height) {
          game.onGoalScored(false);
          removeFromParent();
          _respawn(false);
        }
      }
    }
  }

  void _respawn(bool forPlayer1) {
    if (forPlayer1) {
      game.spawnPuck(true, Vector2(80 + math.Random().nextInt(3) * 80.0, 100));
    } else {
      game.spawnPuck(
        false,
        Vector2(
          80 + math.Random().nextInt(3) * 80.0,
          FoosballGame.boardHeight - 100,
        ),
      );
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!game.canMove(isPlayer1)) return;

    isDragging = true;
    dragStart = event.localPosition;
    dragCurrent = event.localPosition;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!isDragging) return;
    dragCurrent = dragCurrent! + event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!isDragging) return;
    isDragging = false;

    if (dragStart != null && dragCurrent != null) {
      final dragDelta = dragStart! - dragCurrent!;
      velocity = dragDelta * 5.0;
      game.switchTurn();
    }

    dragStart = null;
    dragCurrent = null;
  }
}
