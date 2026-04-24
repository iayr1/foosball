import 'package:flutter/foundation.dart';

@immutable
class GameState {
  final int scoreP1;
  final int scoreP2;
  final bool isPlayer1Turn;
  final String winner;

  const GameState({
    this.scoreP1 = 0,
    this.scoreP2 = 0,
    this.isPlayer1Turn = true,
    this.winner = '',
  });

  GameState copyWith({
    int? scoreP1,
    int? scoreP2,
    bool? isPlayer1Turn,
    String? winner,
  }) {
    return GameState(
      scoreP1: scoreP1 ?? this.scoreP1,
      scoreP2: scoreP2 ?? this.scoreP2,
      isPlayer1Turn: isPlayer1Turn ?? this.isPlayer1Turn,
      winner: winner ?? this.winner,
    );
  }
}
