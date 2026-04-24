import 'package:flutter/foundation.dart';

import '../models/game_state.dart';
import '../models/player.dart';

/// Coordinates turns and winner updates between Flame and Flutter UI.
class GameController extends ChangeNotifier {
  static const int totalPucksPerPlayer = 5;

  final Player topPlayer;
  final Player bottomPlayer;

  GameState _state;
  GameState get state => _state;

  GameController({
    required this.topPlayer,
    required this.bottomPlayer,
  }) : _state = GameState(
          winnerId: null,
          currentTurnId: topPlayer.id,
          blackOnOpponentSide: 0,
          whiteOnOpponentSide: 0,
        );

  bool canControlPlayer(String playerId) {
    return !_state.hasWinner && _state.currentTurnId == playerId;
  }

  void switchTurn() {
    if (_state.hasWinner) return;
    final next = _state.currentTurnId == topPlayer.id ? bottomPlayer.id : topPlayer.id;
    _state = _state.copyWith(currentTurnId: next);
    notifyListeners();
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
      currentTurnId: topPlayer.id,
      blackOnOpponentSide: 0,
      whiteOnOpponentSide: 0,
    );
    notifyListeners();
  }
}
