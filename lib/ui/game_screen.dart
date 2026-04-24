import 'dart:async';

import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import 'control_overlay_widget.dart';
import 'game_board_widget.dart';
import 'scoreboard_widget.dart';

class SlingPuckGameView extends StatefulWidget {
  const SlingPuckGameView({super.key, required this.mode});

  final GameMode mode;

  @override
  State<SlingPuckGameView> createState() => _SlingPuckGameViewState();
}

class _SlingPuckGameViewState extends State<SlingPuckGameView> {
  int _playerScore = 0;
  int _aiScore = 0;
  bool _soundOn = true;
  bool _showHint = true;
  bool _isAiming = true;

  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    _hintTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _showHint = false);
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final boardHeight = media.height * 0.64;

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
                Column(
                  children: [
                    ScoreboardWidget(
                      playerScore: _playerScore,
                      aiScore: _aiScore,
                      isSoundOn: _soundOn,
                      onMenuTap: () => Navigator.of(context).maybePop(),
                      onSoundTap: () => setState(() => _soundOn = !_soundOn),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: boardHeight,
                      width: double.infinity,
                      child: const GameBoardWidget(),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: media.height * 0.18,
                      child: ControlOverlayWidget(
                        isAiming: _isAiming,
                        onUndo: () {
                          // UI only placeholder action.
                          setState(() => _isAiming = !_isAiming);
                        },
                        onBoost: () {
                          // UI only placeholder action.
                          setState(() {
                            _playerScore = (_playerScore + 1) % 8;
                            _aiScore = (_aiScore + 1) % 8;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: media.height * 0.49,
                  left: 0,
                  right: 0,
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
                                spreadRadius: 0.5,
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
}
