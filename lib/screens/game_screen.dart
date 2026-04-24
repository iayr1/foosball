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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'P1: ${state.scoreP1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        Text(
          'P2: ${state.scoreP2}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
      ],
    );
  }
}

class TurnIndicator extends ConsumerWidget {
  const TurnIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    return Center(
      child: Text(
        state.isPlayer1Turn ? "Player 1's Turn" : "Player 2's Turn",
        style: TextStyle(
          color: state.isPlayer1Turn ? Colors.cyanAccent : Colors.orangeAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
    );
  }
}
