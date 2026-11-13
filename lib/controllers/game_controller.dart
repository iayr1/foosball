import 'package:flutter/foundation.dart';

import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../models/player.dart';

enum GameTurn { human, player2, ai, waiting, gameOver }

/// Coordinates turns, AI flow, combos and winner updates between Flame and Flutter UI.
class GameController extends ChangeNotifier {
  final GameMode mode;
  final Player topPlayer;
  final Player bottomPlayer;
  final int pucksPerPlayer;

  /// Solo practice: the top side never shoots and has no pucks.
  final bool solo;

  GameState _state;
  GameState get state => _state;

  GameTurn _turn = GameTurn.human;
  GameTurn get turn => _turn;

  GameTurn? _lastShooter;

  int _sentAtShotTop = 0;
  int _sentAtShotBottom = 0;

  /// Pucks the last shot sent across (for "DOUBLE!" pop-ups), and a counter
  /// that changes every time a new combo happens.
  int lastCombo = 0;
  int comboSerial = 0;
  int bestComboBottom = 0;
  int shotsTaken = 0;

  GameController({required this.mode, required this.topPlayer, required this.bottomPlayer, this.pucksPerPlayer = 5, this.solo = false})
    : _state = GameState(winnerId: null, currentTurnId: bottomPlayer.id, blackOnOpponentSide: 0, whiteOnOpponentSide: 0);

  bool canControlPlayer(String playerId) {
    if (_state.hasWinner || _turn == GameTurn.waiting || _turn == GameTurn.gameOver) {
      return false;
    }

    if (mode == GameMode.vsAI) {
      return _turn == GameTurn.human && playerId == bottomPlayer.id;
    }

    return (_turn == GameTurn.human && playerId == bottomPlayer.id) || (_turn == GameTurn.player2 && playerId == topPlayer.id);
  }

  bool get isAiTurn => mode == GameMode.vsAI && _turn == GameTurn.ai;
  bool get isWaiting => _turn == GameTurn.waiting;

  void registerHumanShot() {
    if (_state.hasWinner) return;
    if (_turn != GameTurn.human && _turn != GameTurn.player2) return;
    _lastShooter = _turn;
    if (_turn == GameTurn.human) shotsTaken++;
    _markShotStart();
    _setTurn(GameTurn.waiting);
  }

  void registerAiShot() {
    if (_turn != GameTurn.ai || _state.hasWinner) return;
    _lastShooter = GameTurn.ai;
    _markShotStart();
    _setTurn(GameTurn.waiting);
  }

  void _markShotStart() {
    _sentAtShotTop = _state.blackOnOpponentSide;
    _sentAtShotBottom = _state.whiteOnOpponentSide;
  }

  /// Called when all pucks settle (speed below threshold).
  void onBoardSettled() {
    if (_state.hasWinner || _turn != GameTurn.waiting) return;

    final bottomShot = _lastShooter == GameTurn.human;
    final delta = bottomShot ? _state.whiteOnOpponentSide - _sentAtShotBottom : _state.blackOnOpponentSide - _sentAtShotTop;
    if (delta >= 2) {
      lastCombo = delta;
      comboSerial++;
      if (bottomShot && delta > bestComboBottom) bestComboBottom = delta;
    }

    if (solo) {
      _setTurn(GameTurn.human);
      return;
    }

    if (mode == GameMode.twoPlayer) {
      _setTurn(_lastShooter == GameTurn.human ? GameTurn.player2 : GameTurn.human);
      return;
    }

    _setTurn(_lastShooter == GameTurn.human ? GameTurn.ai : GameTurn.human);
  }

  void updateProgress({required int blackOnOpponentSide, required int whiteOnOpponentSide}) {
    if (_state.hasWinner) return;
    final winner = _computeWinner(blackOnOpponentSide, whiteOnOpponentSide);
    final changed =
        blackOnOpponentSide != _state.blackOnOpponentSide || whiteOnOpponentSide != _state.whiteOnOpponentSide || winner != null;
    _state = _state.copyWith(blackOnOpponentSide: blackOnOpponentSide, whiteOnOpponentSide: whiteOnOpponentSide, winnerId: winner);

    if (winner != null) {
      _setTurn(GameTurn.gameOver, notify: false);
    }

    if (changed) notifyListeners();
  }

  /// Ends the match with the top side winning (e.g. the clock ran out).
  void forfeitBottom() {
    if (_state.hasWinner) return;
    _state = _state.copyWith(winnerId: topPlayer.id);
    _setTurn(GameTurn.gameOver);
  }

  String? _computeWinner(int blackOnOpponentSide, int whiteOnOpponentSide) {
    if (whiteOnOpponentSide >= pucksPerPlayer) return bottomPlayer.id;
    if (!solo && blackOnOpponentSide >= pucksPerPlayer) return topPlayer.id;
    return null;
  }

  void reset() {
    _state = GameState(winnerId: null, currentTurnId: bottomPlayer.id, blackOnOpponentSide: 0, whiteOnOpponentSide: 0);
    _lastShooter = null;
    lastCombo = 0;
    bestComboBottom = 0;
    shotsTaken = 0;
    _turn = GameTurn.human;
    notifyListeners();
  }

  void _setTurn(GameTurn nextTurn, {bool notify = true}) {
    _turn = nextTurn;
    final turnId = switch (nextTurn) {
      GameTurn.ai => topPlayer.id,
      GameTurn.player2 => topPlayer.id,
      GameTurn.human => bottomPlayer.id,
      GameTurn.waiting => _lastShooter == GameTurn.human ? topPlayer.id : bottomPlayer.id,
      GameTurn.gameOver => _state.currentTurnId,
    };

    _state = _state.copyWith(currentTurnId: turnId);
    if (notify) notifyListeners();
  }
}
