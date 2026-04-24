import 'dart:async' as async;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../controllers/ai_controller.dart';
import '../controllers/game_controller.dart';
import 'board.dart';
import 'goal.dart';
import 'physics.dart';
import 'puck.dart';
import 'wall.dart';

class SlingPuckGame extends FlameGame {
  static final Vector2 fixedGameSize = Vector2(420, 760);
  static const double centerGapWidth = 90;
  static const double wallThickness = 16;

  final GameController controller;
  final PhysicsEngine physics;
  final AiController aiController;

  SlingPuckGame({
    required this.controller,
    PhysicsEngine? physics,
    AiController? aiController,
  })  : physics = physics ?? PhysicsEngine(),
        aiController = aiController ?? AiController();

  final List<Puck> _pucks = <Puck>[];
  final List<Wall> _walls = <Wall>[];
  async.Timer? _aiTimer;

  @override
  Color backgroundColor() => const Color(0xFF3E2713);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.visibleGameSize = fixedGameSize;
    camera.viewfinder.position = fixedGameSize / 2;
    camera.viewfinder.anchor = Anchor.center;

    await world.add(Board(boardSize: fixedGameSize));
    _spawnCenterWall();
    _spawnPucks();

    controller.addListener(_onControllerChanged);
    _publishProgress();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (controller.state.hasWinner) {
      _aiTimer?.cancel();
      for (final puck in _pucks) {
        puck.velocity.setZero();
      }
      return;
    }

    physics.update(
      dt: dt,
      boardSize: fixedGameSize,
      pucks: _pucks,
      walls: _walls,
    );

    _publishProgress();

    if (controller.isWaiting && _allPucksStopped()) {
      controller.onBoardSettled();
    }

    if (controller.isAiTurn && _allPucksStopped()) {
      _scheduleAiShotIfNeeded();
    }
  }

  @override
  void onRemove() {
    _aiTimer?.cancel();
    controller.removeListener(_onControllerChanged);
    super.onRemove();
  }

  void restart() {
    _aiTimer?.cancel();
    controller.reset();
    for (final puck in _pucks) {
      puck.removeFromParent();
    }
    _pucks.clear();
    _spawnPucks();
    _publishProgress();
  }

  void _spawnCenterWall() {
    final y = (fixedGameSize.y / 2) - (wallThickness / 2);
    final leftWidth = (fixedGameSize.x - centerGapWidth) / 2;

    final left = Wall(
      position: Vector2(0, y),
      wallSize: Vector2(leftWidth, wallThickness),
    );
    final right = Wall(
      position: Vector2(leftWidth + centerGapWidth, y),
      wallSize: Vector2(leftWidth, wallThickness),
    );

    _walls
      ..add(left)
      ..add(right);

    world.addAll(_walls);
  }

  void _spawnPucks() {
    const spacing = 62.0;
    const leftPadding = 86.0;
    const topY = 150.0;
    final bottomY = fixedGameSize.y - 150.0;

    for (int i = 0; i < GameController.totalPucksPerPlayer; i++) {
      final x = leftPadding + (i * spacing);
      _addPuck(
        ownerId: controller.topPlayer.id,
        color: controller.topPlayer.puckColor,
        position: Vector2(x, topY),
      );
      _addPuck(
        ownerId: controller.bottomPlayer.id,
        color: controller.bottomPlayer.puckColor,
        position: Vector2(x, bottomY),
      );
    }
  }

  void _addPuck({
    required String ownerId,
    required Color color,
    required Vector2 position,
  }) {
    final isHuman = ownerId == controller.bottomPlayer.id;
    final puck = Puck(
      ownerId: ownerId,
      puckColor: color,
      controller: controller,
      isHuman: isHuman,
      midLineY: midLineY,
      canShoot: canShoot,
      isHumanArea: isHumanArea,
      initialPosition: position,
    );
    _pucks.add(puck);
    world.add(puck);
  }

  double get midLineY => fixedGameSize.y / 2;

  /// Bottom half of the board belongs to the human player.
  bool isHumanArea(Vector2 position) => position.y >= midLineY;

  /// Top half of the board belongs to the AI player.
  bool isAIArea(Vector2 position) => position.y < midLineY;

  /// Safety guard to ensure shots are only triggered from legal territory.
  bool canShoot(Puck puck) {
    if (puck.isHuman && !isHumanArea(puck.position)) return false;
    if (!puck.isHuman && !isAIArea(puck.position)) return false;
    return true;
  }

  void _publishProgress() {
    final mid = fixedGameSize.y / 2;
    final black = _pucks.where((p) => p.ownerId == controller.topPlayer.id);
    final white = _pucks.where((p) => p.ownerId == controller.bottomPlayer.id);

    controller.updateProgress(
      blackOnOpponentSide: Goal.countBlackInOpponentZone(
        blackPucks: black,
        midLineY: mid,
      ),
      whiteOnOpponentSide: Goal.countWhiteInOpponentZone(
        whitePucks: white,
        midLineY: mid,
      ),
    );
  }

  bool _allPucksStopped() => _pucks.every((puck) => !puck.isMoving);

  void _scheduleAiShotIfNeeded() {
    if (_aiTimer?.isActive ?? false) return;

    final delay = Duration(milliseconds: aiController.nextDelayMs());
    _aiTimer = async.Timer(delay, _performAiShot);
  }

  void _performAiShot() {
    if (!controller.isAiTurn || controller.state.hasWinner) return;

    final decision = aiController.chooseShot(
      allPucks: _pucks,
      aiOwnerId: controller.topPlayer.id,
      boardSize: fixedGameSize,
      isAIArea: isAIArea,
    );

    if (decision == null) {
      controller.registerAiShot();
      return;
    }

    if (!canShoot(decision.puck)) {
      controller.registerAiShot();
      return;
    }

    decision.puck.applyShotVelocity(decision.velocity);
    controller.registerAiShot();
  }

  void _onControllerChanged() {
    if (!controller.isAiTurn) {
      _aiTimer?.cancel();
    }
  }
}
