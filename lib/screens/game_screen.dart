import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../widgets/game_board.dart';
import '../widgets/scoreboard.dart';
import 'lose_screen.dart';
import 'pause_dialog.dart';
import 'win_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.mode});

  final GameMode mode;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _soundOn = true;
  bool _showPause = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F0F), Color(0xFF2D1D13)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  children: [
                    Scoreboard(
                      score: '0 - 0',
                      isSoundOn: _soundOn,
                      onMenuTap: () => setState(() => _showPause = true),
                      onSoundTap: () => setState(() => _soundOn = !_soundOn),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: size.width,
                          child: const GameBoard(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 92,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 8,
                            bottom: 12,
                            child: _CircleAction(
                              icon: Icons.undo_rounded,
                              label: 'Undo',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const LoseScreen()),
                              ),
                            ),
                          ),
                          const Align(
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('☝️', style: TextStyle(fontSize: 24)),
                                Text('Drag puck', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 8,
                            bottom: 12,
                            child: _CircleAction(
                              icon: Icons.bolt_rounded,
                              label: 'Power',
                              highlight: true,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const WinScreen()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.black.withOpacity(0.35),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Column(
                        children: [
                          Text('YOUR TURN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                          SizedBox(height: 2),
                          Text('Drag & release to shoot!', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_showPause)
                Container(
                  color: Colors.black54,
                  child: PauseDialog(
                    onResume: () => setState(() => _showPause = false),
                    onRestart: () => setState(() => _showPause = false),
                    onMainMenu: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.label, this.highlight = false, this.onTap});

  final IconData icon;
  final String label;
  final bool highlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xCC151515),
              border: Border.all(color: Colors.white24),
              boxShadow: [
                BoxShadow(
                  color: (highlight ? const Color(0xFFFFC44D) : Colors.white).withOpacity(0.3),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Icon(icon, color: highlight ? const Color(0xFFFFC44D) : Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
