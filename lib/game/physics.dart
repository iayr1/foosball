import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import 'puck.dart';
import 'wall.dart';

/// Physics helper that keeps gameplay deterministic and easy to tune.
class PhysicsEngine {
  static const double restitution = 0.92;

  /// Turned off from Settings > Vibration.
  static bool hapticsEnabled = true;

  /// Called on hard puck-to-puck hits with the contact point and impact speed.
  void Function(Vector2 point, double speed)? onImpact;

  static void _buzz() {
    if (hapticsEnabled) HapticFeedback.lightImpact();
  }

  void update({required double dt, required Vector2 boardSize, required List<Puck> pucks, required List<Wall> walls}) {
    _integratePucks(dt: dt, boardSize: boardSize, pucks: pucks, walls: walls);
    _handlePuckCollisions(pucks);
  }

  void _integratePucks({required double dt, required Vector2 boardSize, required List<Puck> pucks, required List<Wall> walls}) {
    for (final puck in pucks) {
      _clampVelocity(puck);
      puck.position += puck.velocity * dt;
      puck.velocity *= math.pow(puck.frictionPerSecond, dt * 60).toDouble();

      if (puck.velocity.length < 8) {
        puck.velocity.setZero();
      }

      _resolveBoardBounds(puck, boardSize);
      for (final wall in walls) {
        _resolveWallCollision(puck, wall);
      }
    }
  }

  void _resolveBoardBounds(Puck puck, Vector2 boardSize) {
    final r = Puck.radius;

    if (puck.position.x - r < 0) {
      puck.position.x = r;
      puck.velocity.x = puck.velocity.x.abs() * restitution;
      _buzz();
    } else if (puck.position.x + r > boardSize.x) {
      puck.position.x = boardSize.x - r;
      puck.velocity.x = -puck.velocity.x.abs() * restitution;
      _buzz();
    }

    if (puck.position.y - r < 0) {
      puck.position.y = r;
      puck.velocity.y = puck.velocity.y.abs() * restitution;
      _buzz();
    } else if (puck.position.y + r > boardSize.y) {
      puck.position.y = boardSize.y - r;
      puck.velocity.y = -puck.velocity.y.abs() * restitution;
      _buzz();
    }
  }

  void _resolveWallCollision(Puck puck, Wall wall) {
    final nearestX = puck.position.x.clamp(wall.position.x, wall.position.x + wall.size.x);
    final nearestY = puck.position.y.clamp(wall.position.y, wall.position.y + wall.size.y);
    final delta = Vector2(puck.position.x - nearestX, puck.position.y - nearestY);
    final distance = delta.length;

    if (distance <= Puck.radius && distance > 0) {
      final normal = delta / distance;
      final penetration = Puck.radius - distance;
      puck.position += normal * penetration;

      final velocityAlongNormal = puck.velocity.dot(normal);
      if (velocityAlongNormal < 0) {
        puck.velocity -= normal * (1 + restitution) * velocityAlongNormal;
        _buzz();
      }
    }
  }

  void _handlePuckCollisions(List<Puck> pucks) {
    for (int i = 0; i < pucks.length; i++) {
      for (int j = i + 1; j < pucks.length; j++) {
        final a = pucks[i];
        final b = pucks[j];

        final delta = b.position - a.position;
        final distance = delta.length;
        const minDistance = Puck.radius * 2;
        if (distance == 0 || distance >= minDistance) continue;

        final normal = delta / distance;
        final overlap = minDistance - distance;

        a.position -= normal * (overlap * 0.5);
        b.position += normal * (overlap * 0.5);

        final relativeVelocity = b.velocity - a.velocity;
        final separatingSpeed = relativeVelocity.dot(normal);
        if (separatingSpeed > 0) continue;

        final impulse = -(1 + restitution) * separatingSpeed / 2;
        final impulseVector = normal * impulse;

        a.velocity -= impulseVector;
        b.velocity += impulseVector;
        if (hapticsEnabled) HapticFeedback.selectionClick();
        if (-separatingSpeed > 260) {
          onImpact?.call(a.position + normal * Puck.radius, -separatingSpeed);
        }
      }
    }
  }

  void _clampVelocity(Puck puck) {
    if (puck.velocity.length > puck.maxVelocity) {
      puck.velocity.scaleTo(puck.maxVelocity);
    }
  }
}
