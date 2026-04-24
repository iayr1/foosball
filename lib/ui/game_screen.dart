import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../game/sling_puck_game.dart';
import '../models/game_mode.dart';
import '../models/player.dart';
import 'score_widget.dart';
import 'win_dialog.dart';

class SlingPuckGameView extends StatefulWidget {
  const SlingPuckGameView({super.key, required this.mode});

  final GameMode mode;

  @override
  State<SlingPuckGameView> createState() => _SlingPuckGameViewState();
}

class _SlingPuckGameViewState extends State<SlingPuckGameView> {
  late final GameController _controller;
  late final SlingPuckGame _game;

  @override
  void initState() {
    super.initState();
    _controller = GameController(
      topPlayer: Player(
        id: 'top',
        name: widget.mode == GameMode.vsAI ? 'Computer' : 'Player 2',
        puckColor: const Color(0xFF111111),
        startsOnTop: true,
      ),
      bottomPlayer: Player(
        id: 'bottom',
        name: widget.mode == GameMode.vsAI ? 'Human' : 'Player 1',
        puckColor: const Color(0xFFF2F2F2),
        startsOnTop: false,
      ),
    );
    _game = SlingPuckGame(controller: _controller);
    _controller.addListener(_observeWinner);
  }

  @override
  void dispose() {
    _controller.removeListener(_observeWinner);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071317),
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(game: _game),
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: ScoreWidget(controller: _controller),
            ),
            Positioned(
              left: 12,
              top: 72,
              child: FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: FilledButton.icon(
                onPressed: _restartGame,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Restart'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _observeWinner() {
    final winnerId = _controller.state.winnerId;
    if (winnerId == null) return;

    final winnerName = winnerId == _controller.topPlayer.id
        ? _controller.topPlayer.name
        : _controller.bottomPlayer.name;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => WinDialog(
          winnerName: winnerName,
          onRestart: _restartGame,
        ),
      );
    });
  }

  void _restartGame() {
    _game.restart();
  }
}
