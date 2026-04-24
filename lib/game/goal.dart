import 'package:flame/components.dart';

/// Utility methods for deciding whether pucks have crossed to opponent zones.
class Goal {
  static int countBlackInOpponentZone({
    required Iterable<PositionComponent> blackPucks,
    required double midLineY,
  }) {
    return blackPucks.where((puck) => puck.position.y > midLineY).length;
  }

  static int countWhiteInOpponentZone({
    required Iterable<PositionComponent> whitePucks,
    required double midLineY,
  }) {
    return whitePucks.where((puck) => puck.position.y < midLineY).length;
  }
}
