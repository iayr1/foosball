import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../game/sling_puck_game.dart';
import '../models/player.dart';
import 'score_widget.dart';
import 'win_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _controller;
  late final SlingPuckGame _game;

  @override
  void initState() {
    super.initState();
    _controller = GameController(
      topPlayer: const Player(
        id: 'black',
        name: 'Black',
        puckColor: Color(0xFF111111),
        startsOnTop: true,
      ),
      bottomPlayer: const Player(
        id: 'white',
        name: 'White',
        puckColor: Color(0xFFF2F2F2),
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
