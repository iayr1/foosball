import 'package:flutter/foundation.dart';

@immutable
class GameState {
  final int scoreP1;
  final int scoreP2;
  final bool isPlayer1Turn;
  final String winner;
  final int gamesPlayed;
  final String lastWinner;

  const GameState({
    this.scoreP1 = 0,
    this.scoreP2 = 0,
    this.isPlayer1Turn = true,
    this.winner = '',
    this.gamesPlayed = 0,
    this.lastWinner = '',
  });

  GameState copyWith({
    int? scoreP1,
    int? scoreP2,
    bool? isPlayer1Turn,
    String? winner,
    int? gamesPlayed,
    String? lastWinner,
  }) {
    return GameState(
      scoreP1: scoreP1 ?? this.scoreP1,
      scoreP2: scoreP2 ?? this.scoreP2,
      isPlayer1Turn: isPlayer1Turn ?? this.isPlayer1Turn,
      winner: winner ?? this.winner,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      lastWinner: lastWinner ?? this.lastWinner,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'scoreP1': scoreP1,
      'scoreP2': scoreP2,
      'isPlayer1Turn': isPlayer1Turn,
      'winner': winner,
      'gamesPlayed': gamesPlayed,
      'lastWinner': lastWinner,
    };
  }

  factory GameState.fromJson(Map<String, Object?> json) {
    return GameState(
      scoreP1: (json['scoreP1'] as num?)?.toInt() ?? 0,
      scoreP2: (json['scoreP2'] as num?)?.toInt() ?? 0,
      isPlayer1Turn: json['isPlayer1Turn'] as bool? ?? true,
      winner: json['winner'] as String? ?? '',
      gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
      lastWinner: json['lastWinner'] as String? ?? '',
    );
  }
}
