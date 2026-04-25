import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../game/sling_puck_game.dart';
import '../models/game_mode.dart';
import '../models/player.dart';
import 'control_overlay_widget.dart';
import 'game_board_widget.dart';
import 'scoreboard_widget.dart';
import 'win_dialog.dart';

class SlingPuckGameView extends StatefulWidget {
  const SlingPuckGameView({super.key, required this.mode});

  final GameMode mode;

  @override
  State<SlingPuckGameView> createState() => _SlingPuckGameViewState();
}

class _SlingPuckGameViewState extends State<SlingPuckGameView> {
  late final Player _topPlayer;
  late final Player _bottomPlayer;
  late final GameController _controller;
  late final SlingPuckGame _game;

  int _playerScore = 0;
  int _opponentScore = 0;
  int _playerPucksLeft = GameController.totalPucksPerPlayer;
  int _opponentPucksLeft = GameController.totalPucksPerPlayer;

  bool _soundOn = true;
  bool _showHint = true;
  bool _isAiming = true;
  bool _didShowWinDialog = false;

  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();

    _topPlayer = Player(
      id: 'top',
      name: widget.mode == GameMode.vsAI ? 'AI' : 'Player 2',
      puckColor: const Color(0xFF191A1C),
      startsOnTop: true,
    );

    _bottomPlayer = const Player(
      id: 'bottom',
      name: 'You',
      puckColor: Color(0xFFEFEFEF),
      startsOnTop: false,
    );

    _controller = GameController(
      mode: widget.mode,
      topPlayer: _topPlayer,
      bottomPlayer: _bottomPlayer,
    )..addListener(_onGameStateChanged);

    _game = SlingPuckGame(controller: _controller);

    _hintTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _showHint = false);
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF120D0C), Color(0xFF050607)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Stack(
              children: [
                /// 🔥 MAIN CONTENT
                Column(
  children: [
    ScoreboardWidget(
      playerScore: _playerScore,
      opponentScore: _opponentScore,
      playerPucks: _playerPucksLeft,
      opponentPucks: _opponentPucksLeft,
      playerName: _bottomPlayer.name,
      opponentName: _topPlayer.name,
      isSoundOn: _soundOn,
      onMenuTap: () => Navigator.of(context).maybePop(),
      onSoundTap: () => setState(() => _soundOn = !_soundOn),
    ),

    const SizedBox(height: 12),

    Expanded(
      flex: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: GameBoardWidget(
          gameLayer: GameWidget(game: _game),
        ),
      ),
    ),

    Flexible(
      fit: FlexFit.loose,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: ControlOverlayWidget(
          isAiming: _isAiming,
          onUndo: _restartMatch,
          onBoost: () {
            _restartMatch();
          },
        ),
      ),
    ),
  ],
),

                /// 🔥 CENTER HINT (FIXED OVERFLOW ISSUE)
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: _showHint ? 1 : 0,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xD91A1B1D),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0x66FF9F43),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66FF9F43),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Drag to aim • Release to shoot',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _restartMatch() {
    _didShowWinDialog = false;
    _game.restart();
  }

  void _onGameStateChanged() {
    if (!mounted) return;

    final state = _controller.state;
    final playerSent = state.whiteOnOpponentSide;
    final opponentSent = state.blackOnOpponentSide;

    setState(() {
      _playerScore = playerSent;
      _opponentScore = opponentSent;
      _playerPucksLeft = GameController.totalPucksPerPlayer - playerSent;
      _opponentPucksLeft =
          GameController.totalPucksPerPlayer - opponentSent;

      _isAiming = !_controller.isWaiting &&
          !_controller.isAiTurn &&
          !state.hasWinner;
    });

    if (state.hasWinner && !_didShowWinDialog) {
      _didShowWinDialog = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => WinDialog(
            winnerName: state.winnerId == _bottomPlayer.id
                ? _bottomPlayer.name
                : _topPlayer.name,
            onRestart: _restartMatch,
          ),
        );
      });
    }
  }
}