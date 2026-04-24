import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/foosball_game.dart';
import '../state/game_notifier.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to changes to trigger game over
    ref.listen(gameProvider, (previous, next) {
      if (next.winner.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/gameover');
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: FoosballGame(
              onScore: (isP1) {
                ref.read(gameProvider.notifier).scoreGoal(isP1);
              },
              onTurnSwitch: () {
                ref.read(gameProvider.notifier).switchTurn();
              },
              isPlayer1Turn: () => ref.read(gameProvider).isPlayer1Turn,
              isGameOver: () => ref.read(gameProvider).winner.isNotEmpty,
            ),
          ),
          // HUD Overlay
          const Positioned(top: 40, left: 20, right: 20, child: ScoreBoard()),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: TurnIndicator(),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreBoard extends ConsumerWidget {
  const ScoreBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xAA0C1820),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x5544DAB9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ScoreChip(
            label: 'Player 1',
            score: state.scoreP1,
            chipColor: const Color(0xFF2BD7B0),
          ),
          Text(
            'Target: ${GameNotifier.winningScore}',
            style: const TextStyle(
              color: Color(0xFFCEE4DF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          _ScoreChip(
            label: 'Player 2',
            score: state.scoreP2,
            chipColor: const Color(0xFFFFB75E),
          ),
        ],
      ),
    );
  }
}

class TurnIndicator extends ConsumerWidget {
  const TurnIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xAA0C1820),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: state.isPlayer1Turn
                ? const Color(0xCC2BD7B0)
                : const Color(0xCCFFB75E),
          ),
        ),
        child: Text(
          state.isPlayer1Turn ? "Player 1's Turn" : "Player 2's Turn",
          style: TextStyle(
            color: state.isPlayer1Turn
                ? const Color(0xFF79F7DF)
                : const Color(0xFFFFD2A0),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final int score;
  final Color chipColor;

  const _ScoreChip({
    required this.label,
    required this.score,
    required this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: TextStyle(
            color: chipColor,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
