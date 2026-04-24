import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_state.dart';

class GameNotifier extends Notifier<GameState> {
  static const int winningScore = 10;
  static const String _storageKey = 'foosball.game_state.v1';
  SharedPreferences? _preferences;

  @override
  GameState build() {
    _hydrateFromLocalStorage();
    return const GameState();
  }

  void resetGame() {
    state = state.copyWith(
      scoreP1: 0,
      scoreP2: 0,
      isPlayer1Turn: true,
      winner: '',
    );
    _persistState();
  }

  void scoreGoal(bool isPlayer1Scored) {
    if (state.winner.isNotEmpty) return;

    if (isPlayer1Scored) {
      final newScore = state.scoreP1 + 1;
      state = state.copyWith(scoreP1: newScore);
      if (newScore >= winningScore) {
        state = state.copyWith(
          winner: 'Player 1',
          lastWinner: 'Player 1',
          gamesPlayed: state.gamesPlayed + 1,
        );
      }
    } else {
      final newScore = state.scoreP2 + 1;
      state = state.copyWith(scoreP2: newScore);
      if (newScore >= winningScore) {
        state = state.copyWith(
          winner: 'Player 2',
          lastWinner: 'Player 2',
          gamesPlayed: state.gamesPlayed + 1,
        );
      }
    }
    _persistState();
  }

  void switchTurn() {
    if (state.winner.isNotEmpty) return;
    state = state.copyWith(isPlayer1Turn: !state.isPlayer1Turn);
    _persistState();
  }

  Future<void> _hydrateFromLocalStorage() async {
    _preferences ??= await SharedPreferences.getInstance();
    final encodedState = _preferences!.getString(_storageKey);
    if (encodedState == null || encodedState.isEmpty) return;

    final decodedState = jsonDecode(encodedState);
    if (decodedState is! Map<String, dynamic>) return;

    state = GameState.fromJson(decodedState);
  }

  Future<void> _persistState() async {
    _preferences ??= await SharedPreferences.getInstance();
    final encodedState = jsonEncode(state.toJson());
    await _preferences!.setString(_storageKey, encodedState);
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(() {
  return GameNotifier();
});
