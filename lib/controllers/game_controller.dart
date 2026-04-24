import 'package:flutter/foundation.dart';

import '../models/game_state.dart';
import '../models/player.dart';

enum GameTurn { human, ai, waiting, gameOver }

/// Coordinates turns, AI flow and winner updates between Flame and Flutter UI.
class GameController extends ChangeNotifier {
  static const int totalPucksPerPlayer = 5;

  final Player topPlayer;
  final Player bottomPlayer;

  GameState _state;
  GameState get state => _state;

  GameTurn _turn = GameTurn.human;
  GameTurn get turn => _turn;

  GameTurn? _lastShooter;

  GameController({
    required this.topPlayer,
    required this.bottomPlayer,
  }) : _state = GameState(
          winnerId: null,
          currentTurnId: bottomPlayer.id,
          blackOnOpponentSide: 0,
          whiteOnOpponentSide: 0,
        );

  bool canControlPlayer(String playerId) {
    return !_state.hasWinner &&
        _turn == GameTurn.human &&
        playerId == bottomPlayer.id;
  }

  bool get isAiTurn => _turn == GameTurn.ai;
  bool get isWaiting => _turn == GameTurn.waiting;

  void registerHumanShot() {
    if (_turn != GameTurn.human || _state.hasWinner) return;
    _lastShooter = GameTurn.human;
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
        return 'Human';
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
      GameTurn.human => bottomPlayer.id,
      GameTurn.waiting =>
        _lastShooter == GameTurn.human ? topPlayer.id : bottomPlayer.id,
      GameTurn.gameOver => _state.currentTurnId,
    };

    _state = _state.copyWith(currentTurnId: turnId);
    if (notify) {
      notifyListeners();
    }
  }
}
