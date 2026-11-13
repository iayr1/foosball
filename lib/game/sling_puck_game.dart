import 'dart:async' as async;
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../controllers/ai_controller.dart';
import '../controllers/game_controller.dart';
import '../data/catalog.dart';
import '../models/game_mode.dart';
import 'board.dart';
import 'goal.dart';
import 'physics.dart';
import 'puck.dart';
import 'wall.dart';

/// Visual skins for one match.
class MatchSkins {
  final PuckSkin bottomPuck;
  final PuckSkin topPuck;
  final BoardSkin board;
  final BandSkin band;
  final EffectSkin effect;

  const MatchSkins({required this.bottomPuck, required this.topPuck, required this.board, required this.band, required this.effect});
}

class SlingPuckGame extends FlameGame {
  static final Vector2 fixedGameSize = Vector2(420, 760);
  static const double centerGapWidth = 90;
  static const double wallThickness = 16;

  final GameController controller;
  final PhysicsEngine physics;
  final AiController aiController;
  final MatchSkins skins;
  final bool Function() showAimGuide;
  final void Function(double? power)? onAim;

  SlingPuckGame({
    required this.controller,
    required this.skins,
    required this.showAimGuide,
    this.onAim,
    PhysicsEngine? physics,
    AiController? aiController,
  }) : physics = physics ?? PhysicsEngine(),
       aiController = aiController ?? AiController();

  final List<Puck> _pucks = <Puck>[];
  final List<Wall> _walls = <Wall>[];
  async.Timer? _aiTimer;
  late final _EffectsLayer _effects;
  double _shake = 0;
  final _rnd = math.Random();

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    final framed = fixedGameSize + Vector2.all(Board.frameWidth * 2 + 8);
    camera.viewfinder.visibleGameSize = framed;
    camera.viewfinder.position = fixedGameSize / 2;
    camera.viewfinder.anchor = Anchor.center;

    await world.add(
      Board(boardSize: fixedGameSize, skin: skins.board, band: skins.band, gapWidth: centerGapWidth, soloTop: controller.solo),
    );
    _spawnCenterWall();
    _effects = _EffectsLayer(pucks: _pucks, effect: skins.effect);
    await world.add(_effects);
    _spawnPucks();

    physics.onImpact = (point, speed) {
      _effects.addImpact(point, speed);
      if (skins.effect.kind == TrailKind.quake) _shake = math.min(10, speed / 70);
    };

    controller.addListener(_onControllerChanged);
    _publishProgress();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_shake > 0) {
      _shake = math.max(0, _shake - dt * 30);
      camera.viewfinder.position = fixedGameSize / 2 + Vector2((_rnd.nextDouble() - 0.5) * _shake, (_rnd.nextDouble() - 0.5) * _shake);
    }

    if (controller.state.hasWinner) {
      _aiTimer?.cancel();
      for (final puck in _pucks) {
        puck.velocity.setZero();
      }
      return;
    }

    physics.update(dt: dt, boardSize: fixedGameSize, pucks: _pucks, walls: _walls);
    _publishProgress();

    if (controller.isWaiting && _allPucksStopped()) controller.onBoardSettled();
    if (controller.isAiTurn && _allPucksStopped()) _scheduleAiShotIfNeeded();
  }

  @override
  void onRemove() {
    _aiTimer?.cancel();
    controller.removeListener(_onControllerChanged);
    super.onRemove();
  }

  void setPaused(bool value) {
    paused = value;
    if (value) _aiTimer?.cancel();
  }

  void restart() {
    _aiTimer?.cancel();
    controller.reset();
    for (final puck in _pucks) {
      puck.removeFromParent();
    }
    _pucks.clear();
    _effects.clear();
    _spawnPucks();
    _publishProgress();
  }

  void _spawnCenterWall() {
    final y = (fixedGameSize.y / 2) - (wallThickness / 2);
    final sideWidth = (fixedGameSize.x - centerGapWidth) / 2;

    _walls
      ..add(
        Wall(
          position: Vector2(0, y),
          wallSize: Vector2(sideWidth, wallThickness),
          color: skins.board.frame,
          highlight: skins.board.frameLight,
        ),
      )
      ..add(
        Wall(
          position: Vector2(sideWidth + centerGapWidth, y),
          wallSize: Vector2(sideWidth, wallThickness),
          color: skins.board.frame,
          highlight: skins.board.frameLight,
        ),
      );
    world.addAll(_walls);
  }

  void _spawnPucks() {
    final n = controller.pucksPerPlayer;
    const margin = 70.0;
    final spacing = n > 1 ? (fixedGameSize.x - margin * 2) / (n - 1) : 0.0;
    const topY = 150.0;
    final bottomY = fixedGameSize.y - 150.0;

    for (int i = 0; i < n; i++) {
      final x = n > 1 ? margin + i * spacing : fixedGameSize.x / 2;
      // Stagger rows a little so pucks do not sit in one straight line.
      final wobble = (i.isEven ? 0.0 : 22.0);
      if (!controller.solo) {
        _addPuck(ownerId: controller.topPlayer.id, skin: skins.topPuck, position: Vector2(x, topY + wobble));
      }
      _addPuck(ownerId: controller.bottomPlayer.id, skin: skins.bottomPuck, position: Vector2(x, bottomY - wobble));
    }
  }

  void _addPuck({required String ownerId, required PuckSkin skin, required Vector2 position}) {
    final isHuman = controller.mode == GameMode.twoPlayer ? true : ownerId == controller.bottomPlayer.id;
    final puck = Puck(
      ownerId: ownerId,
      skin: skin,
      controller: controller,
      isHuman: isHuman,
      midLineY: midLineY,
      canShoot: canShoot,
      isHumanArea: isHumanArea,
      isAIArea: isAIArea,
      showAimGuide: showAimGuide,
      onAim: onAim,
      initialPosition: position,
    );
    _pucks.add(puck);
    world.add(puck);
  }

  double get midLineY => fixedGameSize.y / 2;

  bool isHumanArea(Vector2 position) => position.y >= midLineY;
  bool isAIArea(Vector2 position) => position.y < midLineY;

  bool canShoot(Puck puck) {
    if (controller.mode == GameMode.vsAI) {
      if (puck.isHuman && !isHumanArea(puck.position)) return false;
      if (!puck.isHuman && !isAIArea(puck.position)) return false;
      return true;
    }
    if (puck.ownerId == controller.bottomPlayer.id && !isHumanArea(puck.position)) return false;
    if (puck.ownerId == controller.topPlayer.id && !isAIArea(puck.position)) return false;
    return true;
  }

  void _publishProgress() {
    final mid = fixedGameSize.y / 2;
    final top = _pucks.where((p) => p.ownerId == controller.topPlayer.id);
    final bottom = _pucks.where((p) => p.ownerId == controller.bottomPlayer.id);

    controller.updateProgress(
      blackOnOpponentSide: Goal.countBlackInOpponentZone(blackPucks: top, midLineY: mid),
      whiteOnOpponentSide: Goal.countWhiteInOpponentZone(whitePucks: bottom, midLineY: mid),
    );
  }

  bool _allPucksStopped() => _pucks.every((puck) => !puck.isMoving);

  void _scheduleAiShotIfNeeded() {
    if (controller.mode != GameMode.vsAI || controller.solo) return;
    if (_aiTimer?.isActive ?? false) return;
    _aiTimer = async.Timer(Duration(milliseconds: aiController.nextDelayMs()), _performAiShot);
  }

  void _performAiShot() {
    if (paused) return;
    if (controller.mode != GameMode.vsAI) return;
    if (!controller.isAiTurn || controller.state.hasWinner) return;

    final decision = aiController.chooseShot(
      allPucks: _pucks,
      aiOwnerId: controller.topPlayer.id,
      boardSize: fixedGameSize,
      gapWidth: centerGapWidth,
      isAIArea: isAIArea,
    );

    if (decision == null || !canShoot(decision.puck)) {
      controller.registerAiShot();
      return;
    }

    decision.puck.applyShotVelocity(decision.velocity);
    controller.registerAiShot();
  }

  void _onControllerChanged() {
    if (!controller.isAiTurn) _aiTimer?.cancel();
  }
}

class _Particle {
  _Particle(this.pos, this.life, this.size, this.color);
  final Vector2 pos;
  double life;
  final double size;
  final Color color;
}

class _Ring {
  _Ring(this.pos, this.strength);
  final Vector2 pos;
  final double strength;
  double t = 0;
}

/// Trails behind moving pucks and rings on hard hits.
class _EffectsLayer extends Component {
  _EffectsLayer({required this.pucks, required this.effect}) : super(priority: 15);

  final List<Puck> pucks;
  final EffectSkin effect;
  final List<_Particle> _particles = [];
  final List<_Ring> _rings = [];
  final _rnd = math.Random();
  double _emit = 0;

  void clear() {
    _particles.clear();
    _rings.clear();
  }

  void addImpact(Vector2 point, double speed) {
    if (_rings.length > 12) return;
    _rings.add(_Ring(point.clone(), (speed / 600).clamp(0.3, 1.5)));
  }

  @override
  void update(double dt) {
    for (final p in _particles) {
      p.life -= dt * (effect.kind == TrailKind.comet ? 2.2 : 3.2);
    }
    _particles.removeWhere((p) => p.life <= 0);
    for (final r in _rings) {
      r.t += dt * 2.6;
    }
    _rings.removeWhere((r) => r.t >= 1);

    if (effect.kind == TrailKind.none || effect.kind == TrailKind.quake) return;
    _emit += dt;
    if (_emit < 1 / 45) return;
    _emit = 0;
    for (final puck in pucks) {
      if (puck.velocity.length2 < 160 * 160) continue;
      final jitter = effect.kind == TrailKind.spark
          ? Vector2((_rnd.nextDouble() - 0.5) * 14, (_rnd.nextDouble() - 0.5) * 14)
          : Vector2.zero();
      _particles.add(
        _Particle(
          puck.position + jitter,
          1,
          effect.kind == TrailKind.comet ? Puck.radius * 0.9 : 3 + _rnd.nextDouble() * 3,
          effect.kind == TrailKind.comet ? puck.skin.base : effect.color,
        ),
      );
    }
    if (_particles.length > 240) _particles.removeRange(0, _particles.length - 240);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint();
    for (final p in _particles) {
      paint.color = p.color.withValues(alpha: (p.life * 0.55).clamp(0, 1));
      canvas.drawCircle(p.pos.toOffset(), p.size * (0.4 + p.life * 0.6), paint);
    }
    final ringPaint = Paint()..style = PaintingStyle.stroke;
    final ringColor = effect.kind == TrailKind.quake ? effect.color : Colors.white;
    for (final r in _rings) {
      ringPaint
        ..strokeWidth = 3 * (1 - r.t) + 1
        ..color = ringColor.withValues(alpha: (1 - r.t) * 0.7);
      canvas.drawCircle(r.pos.toOffset(), 8 + r.t * 30 * r.strength, ringPaint);
    }
  }
}
