import 'package:flutter/foundation.dart';

import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../models/player.dart';

enum GameTurn { human, player2, ai, waiting, gameOver }

/// Coordinates turns, AI flow and winner updates between Flame and Flutter UI.
class GameController extends ChangeNotifier {
  static const int totalPucksPerPlayer = 5;

  final GameMode mode;
  final Player topPlayer;
  final Player bottomPlayer;

  GameState _state;
  GameState get state => _state;

  GameTurn _turn = GameTurn.human;
  GameTurn get turn => _turn;

  GameTurn? _lastShooter;

  GameController({
    required this.mode,
    required this.topPlayer,
    required this.bottomPlayer,
  }) : _state = GameState(
          winnerId: null,
          currentTurnId: bottomPlayer.id,
          blackOnOpponentSide: 0,
          whiteOnOpponentSide: 0,
        );

  bool canControlPlayer(String playerId) {
    if (_state.hasWinner || _turn == GameTurn.waiting || _turn == GameTurn.gameOver) {
      return false;
    }

    if (mode == GameMode.vsAI) {
      return _turn == GameTurn.human && playerId == bottomPlayer.id;
    }

    return (_turn == GameTurn.human && playerId == bottomPlayer.id) ||
        (_turn == GameTurn.player2 && playerId == topPlayer.id);
  }

  bool get isAiTurn => mode == GameMode.vsAI && _turn == GameTurn.ai;
  bool get isWaiting => _turn == GameTurn.waiting;

  void registerHumanShot() {
    if (_state.hasWinner) return;
    if (_turn != GameTurn.human && _turn != GameTurn.player2) return;
    _lastShooter = _turn;
    _setTurn(GameTurn.waiting);
  }

  void registerAiShot() {
    if (_turn != GameTurn.ai || _state.hasWinner) return;
    _lastShooter = GameTurn.ai;
    _setTurn(GameTurn.waiting);
  }

  /// Called when all pucks settle (speed below threshold).
  void onBoardSettled() {
    if (_state.hasWinner || _turn != GameTurn.waiting) return;

    if (mode == GameMode.twoPlayer) {
      _setTurn(
        _lastShooter == GameTurn.human ? GameTurn.player2 : GameTurn.human,
      );
      return;
    }

    if (_lastShooter == GameTurn.human) {
      _setTurn(GameTurn.ai);
      return;
    }

    _setTurn(GameTurn.human);
  }

  void updateProgress({
    required int blackOnOpponentSide,
    required int whiteOnOpponentSide,
  }) {
    final winner = _computeWinner(blackOnOpponentSide, whiteOnOpponentSide);
    _state = _state.copyWith(
      blackOnOpponentSide: blackOnOpponentSide,
      whiteOnOpponentSide: whiteOnOpponentSide,
      winnerId: winner,
    );

    if (winner != null) {
      _setTurn(GameTurn.gameOver, notify: false);
    }

    notifyListeners();
  }

  String? _computeWinner(int blackOnOpponentSide, int whiteOnOpponentSide) {
    if (blackOnOpponentSide == totalPucksPerPlayer) {
      return topPlayer.id;
    }
    if (whiteOnOpponentSide == totalPucksPerPlayer) {
      return bottomPlayer.id;
    }
    return null;
  }

  void reset() {
    _state = GameState(
      winnerId: null,
      currentTurnId: bottomPlayer.id,
      blackOnOpponentSide: 0,
      whiteOnOpponentSide: 0,
    );
    _lastShooter = null;
    _turn = GameTurn.human;
    notifyListeners();
  }

  String get turnLabel {
    switch (_turn) {
      case GameTurn.human:
        return mode == GameMode.vsAI ? 'Human' : bottomPlayer.name;
      case GameTurn.player2:
        return topPlayer.name;
      case GameTurn.ai:
        return 'Computer';
      case GameTurn.waiting:
        return 'Waiting';
      case GameTurn.gameOver:
        return 'Game Over';
    }
  }

  void _setTurn(GameTurn nextTurn, {bool notify = true}) {
    _turn = nextTurn;
    final turnId = switch (nextTurn) {
      GameTurn.ai => topPlayer.id,
      GameTurn.player2 => topPlayer.id,
      GameTurn.human => bottomPlayer.id,
      GameTurn.waiting => _resolveWaitingTurnId(),
      GameTurn.gameOver => _state.currentTurnId,
    };

    _state = _state.copyWith(currentTurnId: turnId);
    if (notify) {
      notifyListeners();
    }
  }

  String _resolveWaitingTurnId() {
    if (_lastShooter == null) {
      return _state.currentTurnId;
    }
    if (mode == GameMode.twoPlayer) {
      return _lastShooter == GameTurn.human ? topPlayer.id : bottomPlayer.id;
    }
    return _lastShooter == GameTurn.human ? topPlayer.id : bottomPlayer.id;
  }
}
