/// Immutable state object used by the UI layer.
class GameState {
  final String? winnerId;
  final String currentTurnId;
  final int blackOnOpponentSide;
  final int whiteOnOpponentSide;

  const GameState({
    required this.winnerId,
    required this.currentTurnId,
    required this.blackOnOpponentSide,
    required this.whiteOnOpponentSide,
  });

  bool get hasWinner => winnerId != null;

  GameState copyWith({
    String? winnerId,
    String? currentTurnId,
    int? blackOnOpponentSide,
    int? whiteOnOpponentSide,
    bool clearWinner = false,
  }) {
    return GameState(
      winnerId: clearWinner ? null : (winnerId ?? this.winnerId),
      currentTurnId: currentTurnId ?? this.currentTurnId,
      blackOnOpponentSide: blackOnOpponentSide ?? this.blackOnOpponentSide,
      whiteOnOpponentSide: whiteOnOpponentSide ?? this.whiteOnOpponentSide,
    );
  }
}
