import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_notifier.dart';

class GameOverScreen extends ConsumerWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final winner = state.winner;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C0F16), Color(0xFF080A10)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF31D0AA), width: 2),
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xE6141B27),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$winner Wins!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 38,
                    color: Color(0xFFE6FFF8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Final Score ${state.scoreP1} - ${state.scoreP2}',
                  style: const TextStyle(color: Color(0xFF96C4B7), fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Matches played: ${state.gamesPlayed}',
                  style: const TextStyle(color: Color(0xFF96C4B7), fontSize: 14),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    ref.read(gameProvider.notifier).resetGame();
                    Navigator.pushReplacementNamed(context, '/game');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF31D0AA),
                    foregroundColor: const Color(0xFF0A1C1E),
                    minimumSize: const Size(220, 52),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Play Again'),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                  child: const Text(
                    'Back to Menu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
