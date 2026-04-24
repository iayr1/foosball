import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/game_flow_controller.dart';
import '../models/game_mode.dart';
import 'game_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key, required this.flowController});

  final GameFlowController flowController;

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _demoController;
  Timer? _autoTimer;

  GameMode get _mode => widget.flowController.selectedMode ?? GameMode.twoPlayer;

  @override
  void initState() {
    super.initState();
    _demoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    _autoTimer = Timer(const Duration(seconds: 6), _startGame);
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _demoController.dispose();
    super.dispose();
  }

  void _startGame() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      _fadeRoute(GameScreen(mode: _mode)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071317),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _startGame,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Color(0xFF90E7D3), fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'How to play',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Drag and release to shoot',
                style: TextStyle(color: Color(0xFF9BC8BC), fontSize: 17),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1A1E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF1E6455)),
                      ),
                      child: AnimatedBuilder(
                        animation: _demoController,
                        builder: (context, child) {
                          final t = Curves.easeInOut.transform(
                            _demoController.value,
                          );
                          final puckX = 26 + (t * 190);
                          final arrowOffset = -20 + (t * 30);
                          return Stack(
                            children: [
                              const Positioned.fill(
                                child: Center(
                                  child: Divider(
                                    color: Color(0xFF1A4038),
                                    thickness: 2,
                                    height: 2,
                                    indent: 18,
                                    endIndent: 18,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: puckX,
                                bottom: 66,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF31D0AA),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 40 + arrowOffset,
                                bottom: 120,
                                child: const Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF9DFFEA),
                                  size: 36,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.touch_app,
                label: 'Drag → Aim → Release',
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.sports_score,
                label: 'Send all pucks to opponent side',
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF31D0AA),
                    foregroundColor: const Color(0xFF07231C),
                    minimumSize: const Size.fromHeight(54),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(
                    _mode == GameMode.vsAI ? 'Start vs AI' : 'Start 2 Player Game',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF8FD5C4)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Color(0xFFAFD5CC))),
      ],
    );
  }
}

Route<T> _fadeRoute<T>(Widget child) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => child,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
