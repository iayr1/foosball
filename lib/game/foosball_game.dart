import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'components/board.dart';
import 'components/puck.dart';

class FoosballGame extends FlameGame with HasCollisionDetection {
  static const double boardWidth = 400;
  static const double boardHeight = 800;
  static const double gateWidth = 60;
  static const double puckRadius = 15;
  static const double friction = 0.98;

  // Callbacks to interact with Riverpod
  final void Function(bool) onScore;
  final VoidCallback onTurnSwitch;
  final bool Function() isPlayer1Turn;
  final bool Function() isGameOver;

  FoosballGame({
    required this.onScore,
    required this.onTurnSwitch,
    required this.isPlayer1Turn,
    required this.isGameOver,
  });

  @override
  Color backgroundColor() => const Color(0xFF222222);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Camera Setup
    camera.viewfinder.visibleGameSize = Vector2(boardWidth, boardHeight);
    camera.viewfinder.position = Vector2(boardWidth / 2, boardHeight / 2);
    camera.viewfinder.anchor = Anchor.center;

    // Add Board to World
    world.add(BoardComponent());

    resetGame();
  }

  void resetGame() {
    // Clear existing pucks
    world.children.whereType<Puck>().forEach((p) => p.removeFromParent());

    // Spawn Pucks
    // P1 (Black, Top)
    for (int i = 0; i < 4; i++) {
      spawnPuck(true, Vector2(80 + i * 80.0, 100));
    }
    // P2 (White, Bottom)
    for (int i = 0; i < 4; i++) {
      spawnPuck(false, Vector2(80 + i * 80.0, boardHeight - 100));
    }
  }

  void spawnPuck(bool isPlayer1, Vector2 position) {
    world.add(Puck(isPlayer1: isPlayer1, initialPosition: position));
  }

  void onGoalScored(bool isPlayer1Scored) {
    onScore(isPlayer1Scored);
  }

  void switchTurn() {
    onTurnSwitch();
  }

  bool canMove(bool isPlayer1) {
    if (isGameOver()) return false;
    return isPlayer1 == isPlayer1Turn();
  }
}
