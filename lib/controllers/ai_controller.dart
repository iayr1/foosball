import 'dart:math' as math;

import 'package:flame/components.dart';

import '../game/puck.dart';

class AiShotDecision {
  final Puck puck;
  final Vector2 velocity;

  const AiShotDecision({required this.puck, required this.velocity});
}

class AiController {
  AiController({math.Random? random}) : _random = random ?? math.Random();

  final math.Random _random;

  int nextDelayMs() => 500 + _random.nextInt(701);

  AiShotDecision? chooseShot({
    required Iterable<Puck> allPucks,
    required String aiOwnerId,
    required Vector2 boardSize,
  }) {
    final aiPucks = allPucks
        .where((puck) => puck.ownerId == aiOwnerId)
        .where((puck) => !puck.isMoving)
        .toList();

    if (aiPucks.isEmpty) return null;

    final centerGap = Vector2(boardSize.x / 2, boardSize.y / 2);

    aiPucks.sort((a, b) {
      final da = (a.position - centerGap).length2;
      final db = (b.position - centerGap).length2;
      return da.compareTo(db);
    });

    final puck = aiPucks.first;
    final target = _targetWithHumanLikeError(centerGap);
    var direction = target - puck.position;
    if (direction.length2 < 1) {
      direction = Vector2(0, 1);
    }

    final angleNoise = (_random.nextDouble() - 0.5) * 0.28;
    direction = direction.normalized()..rotate(angleNoise);

    final basePower = 700.0;
    final powerNoise = (_random.nextDouble() - 0.5) * 280;
    final power = (basePower + powerNoise).clamp(420.0, 940.0);

    return AiShotDecision(
      puck: puck,
      velocity: direction * power,
    );
  }

  Vector2 _targetWithHumanLikeError(Vector2 centerGap) {
    final shouldMiss = _random.nextDouble() < 0.18;
    if (!shouldMiss) {
      return centerGap;
    }

    return centerGap +
        Vector2(
          (_random.nextDouble() - 0.5) * 120,
          (_random.nextDouble() - 0.5) * 70,
        );
  }
}
