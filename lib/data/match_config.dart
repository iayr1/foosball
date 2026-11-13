import '../models/game_mode.dart';

enum Difficulty { easy, normal, hard, legend }

extension DifficultyX on Difficulty {
  String get label => switch (this) {
    Difficulty.easy => 'Easy',
    Difficulty.normal => 'Normal',
    Difficulty.hard => 'Hard',
    Difficulty.legend => 'Legend',
  };

  String get botName => switch (this) {
    Difficulty.easy => 'Pip',
    Difficulty.normal => 'Rook',
    Difficulty.hard => 'Vex',
    Difficulty.legend => 'Nova',
  };

  int get winCoins => switch (this) {
    Difficulty.easy => 40,
    Difficulty.normal => 70,
    Difficulty.hard => 120,
    Difficulty.legend => 200,
  };

  int get winXp => switch (this) {
    Difficulty.easy => 25,
    Difficulty.normal => 35,
    Difficulty.hard => 45,
    Difficulty.legend => 60,
  };
}

/// How a match is played: who is on the other side, timers, and rewards.
enum PlayStyle { vsAi, passAndPlay, timeAttack, daily, tournament, practice }

class MatchConfig {
  final PlayStyle style;
  final Difficulty difficulty;
  final int pucksPerSide;

  /// Seconds on the clock; null means no time limit.
  final int? timeLimit;

  /// 1-based round inside a tournament run.
  final int tournamentRound;

  /// Academy lesson index for practice matches.
  final int? lesson;

  const MatchConfig({
    required this.style,
    this.difficulty = Difficulty.normal,
    this.pucksPerSide = 5,
    this.timeLimit,
    this.tournamentRound = 1,
    this.lesson,
  });

  /// Solo modes have no opponent shots: clear your side on your own.
  bool get isSolo => style == PlayStyle.timeAttack || style == PlayStyle.practice;

  GameMode get engineMode => style == PlayStyle.passAndPlay ? GameMode.twoPlayer : GameMode.vsAI;

  String get title => switch (style) {
    PlayStyle.vsAi => 'Vs ${difficulty.botName}',
    PlayStyle.passAndPlay => 'Pass & Play',
    PlayStyle.timeAttack => 'Time Attack',
    PlayStyle.daily => 'Daily Challenge',
    PlayStyle.tournament => 'Tournament · Round $tournamentRound',
    PlayStyle.practice => 'Academy',
  };

  String get opponentName => switch (style) {
    PlayStyle.passAndPlay => 'Player 2',
    PlayStyle.timeAttack || PlayStyle.practice => 'Target side',
    _ => '${difficulty.botName} · ${difficulty.label}',
  };

  MatchConfig copyWith({int? tournamentRound, Difficulty? difficulty}) => MatchConfig(
    style: style,
    difficulty: difficulty ?? this.difficulty,
    pucksPerSide: pucksPerSide,
    timeLimit: timeLimit,
    tournamentRound: tournamentRound ?? this.tournamentRound,
    lesson: lesson,
  );

  static const tournamentLadder = [Difficulty.normal, Difficulty.hard, Difficulty.legend];

  static MatchConfig tournament(int round) =>
      MatchConfig(style: PlayStyle.tournament, difficulty: tournamentLadder[(round - 1).clamp(0, 2)], tournamentRound: round);

  static MatchConfig daily() => const MatchConfig(style: PlayStyle.daily, difficulty: Difficulty.hard, timeLimit: 90);

  static MatchConfig timeAttack(int pucks) => MatchConfig(style: PlayStyle.timeAttack, pucksPerSide: pucks, timeLimit: 15 + pucks * 6);
}
