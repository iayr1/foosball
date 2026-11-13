import 'dart:math' as math;

import 'package:flame/components.dart';

import '../data/match_config.dart';
import '../game/puck.dart';

class AiShotDecision {
  final Puck puck;
  final Vector2 velocity;

  const AiShotDecision({required this.puck, required this.velocity});
}

/// Bot opponent. Higher difficulties pick clearer lanes, judge power from
/// distance, and make fewer aiming mistakes.
class AiController {
  AiController({this.difficulty = Difficulty.normal, math.Random? random}) : _random = random ?? math.Random();

  final Difficulty difficulty;
  final math.Random _random;

  double get _missChance => switch (difficulty) {
    Difficulty.easy => 0.38,
    Difficulty.normal => 0.2,
    Difficulty.hard => 0.09,
    Difficulty.legend => 0.03,
  };

  double get _angleNoise => switch (difficulty) {
    Difficulty.easy => 0.5,
    Difficulty.normal => 0.28,
    Difficulty.hard => 0.12,
    Difficulty.legend => 0.05,
  };

  double get _powerNoise => switch (difficulty) {
    Difficulty.easy => 360,
    Difficulty.normal => 240,
    Difficulty.hard => 140,
    Difficulty.legend => 70,
  };

  bool get _smart => difficulty == Difficulty.hard || difficulty == Difficulty.legend;

  int nextDelayMs() => switch (difficulty) {
    Difficulty.easy => 900 + _random.nextInt(700),
    Difficulty.normal => 650 + _random.nextInt(600),
    Difficulty.hard => 450 + _random.nextInt(450),
    Difficulty.legend => 350 + _random.nextInt(300),
  };

  AiShotDecision? chooseShot({
    required Iterable<Puck> allPucks,
    required String aiOwnerId,
    required Vector2 boardSize,
    required double gapWidth,
    required bool Function(Vector2 position) isAIArea,
  }) {
    final all = allPucks.toList();
    final valid = all.where((p) => p.ownerId == aiOwnerId && !p.isMoving && isAIArea(p.position)).toList();
    if (valid.isEmpty) return null;

    final mid = boardSize.y / 2;
    final gapLeft = boardSize.x / 2 - gapWidth / 2 + Puck.radius + 2;
    final gapRight = boardSize.x / 2 + gapWidth / 2 - Puck.radius - 2;

    Puck best = valid.first;
    Vector2 bestTarget = Vector2(boardSize.x / 2, mid + 80);
    var bestScore = double.infinity;

    for (final puck in valid) {
      // Aim for the point of the gap closest to the puck's lane.
      final gx = _smart ? puck.position.x.clamp(gapLeft, gapRight).toDouble() : boardSize.x / 2;
      final target = Vector2(gx, mid + 80);
      final dist = (target - puck.position).length;
      final blockers = _smart ? _countBlockers(puck, target, all) : 0;
      final score = dist + blockers * 420;
      if (score < bestScore) {
        bestScore = score;
        best = puck;
        bestTarget = target;
      }
    }

    var target = bestTarget;
    if (_random.nextDouble() < _missChance) {
      target += Vector2((_random.nextDouble() - 0.5) * 160, (_random.nextDouble() - 0.5) * 80);
    }

    var direction = target - best.position;
    if (direction.length2 < 1) direction = Vector2(0, 1);
    direction = direction.normalized()..rotate((_random.nextDouble() - 0.5) * _angleNoise);

    final distance = (bestTarget - best.position).length;
    // Friction loses ~10% per frame-second; this power carries the puck past the gap.
    final judged = (distance + 150) * 0.95;
    final base = _smart ? judged : 700.0;
    final power = (base + (_random.nextDouble() - 0.5) * _powerNoise).clamp(420.0, 960.0);

    return AiShotDecision(puck: best, velocity: direction * power);
  }

  int _countBlockers(Puck shooter, Vector2 target, List<Puck> all) {
    final a = shooter.position;
    final ab = target - a;
    final len2 = ab.length2;
    if (len2 == 0) return 0;
    var count = 0;
    for (final p in all) {
      if (identical(p, shooter)) continue;
      final t = ((p.position - a).dot(ab) / len2).clamp(0.0, 1.0);
      final closest = a + ab * t;
      if ((p.position - closest).length < Puck.radius * 2.1) count++;
    }
    return count;
  }
}
