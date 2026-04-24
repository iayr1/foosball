import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_state.dart';

class GameNotifier extends Notifier<GameState> {
  static const int winningScore = 10;

  @override
  GameState build() {
    return const GameState();
  }

  void resetGame() {
    state = const GameState();
  }

  void scoreGoal(bool isPlayer1Scored) {
    if (state.winner.isNotEmpty) return;

    if (isPlayer1Scored) {
      final newScore = state.scoreP1 + 1;
      state = state.copyWith(scoreP1: newScore);
      if (newScore >= winningScore) {
        state = state.copyWith(winner: 'Player 1');
      }
    } else {
      final newScore = state.scoreP2 + 1;
      state = state.copyWith(scoreP2: newScore);
      if (newScore >= winningScore) {
        state = state.copyWith(winner: 'Player 2');
      }
    }
  }

  void switchTurn() {
    if (state.winner.isNotEmpty) return;
    state = state.copyWith(isPlayer1Turn: !state.isPlayer1Turn);
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(() {
  return GameNotifier();
});
