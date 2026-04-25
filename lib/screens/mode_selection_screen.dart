import 'package:flutter/material.dart';

import '../controllers/game_flow_controller.dart';
import '../models/game_mode.dart';
import '../widgets/custom_button.dart';
import 'mode_bottom_screens.dart';
import 'tutorial_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key, required this.flowController});

  final GameFlowController flowController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF11100F), Color(0xFF281A11)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.2,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'SLING PUCK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    CustomButton(
                      title: '2 PLAYER',
                      subtitle: 'Play with Friend',
                      icon: const Text('👥', style: TextStyle(fontSize: 24)),
                      gradient: const LinearGradient(colors: [Color(0xFF4A9BFF), Color(0xFF295EC9)]),
                      onTap: () => _goTutorial(context, GameMode.twoPlayer),
                    ),
                    const SizedBox(height: 14),
                    CustomButton(
                      title: 'VS AI',
                      subtitle: 'Play against AI',
                      icon: const Text('🤖', style: TextStyle(fontSize: 24)),
                      gradient: const LinearGradient(colors: [Color(0xFF875DFF), Color(0xFF5A38CC)]),
                      onTap: () => _goTutorial(context, GameMode.vsAI),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _BottomCircleIcon(
                          icon: Icons.school_rounded,
                          label: 'Academy',
                          onTap: () => _openBottomScreen(context, const AcademyScreen()),
                        ),
                        _BottomCircleIcon(
                          icon: Icons.emoji_events_rounded,
                          label: 'Achievements',
                          onTap: () => _openBottomScreen(context, const AchievementsScreen()),
                        ),
                        _BottomCircleIcon(
                          icon: Icons.store_rounded,
                          label: 'Store',
                          onTap: () => _openBottomScreen(context, const StoreScreen()),
                        ),
                        _BottomCircleIcon(
                          icon: Icons.settings_rounded,
                          label: 'Settings',
                          onTap: () => _openBottomScreen(context, const SettingsScreen()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goTutorial(BuildContext context, GameMode mode) {
    flowController.setMode(mode);
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => TutorialScreen(flowController: flowController),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _openBottomScreen(BuildContext context, Widget child) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => child,
        transitionsBuilder: (_, animation, __, page) =>
            FadeTransition(opacity: animation, child: page),
      ),
    );
  }
}

class _BottomCircleIcon extends StatelessWidget {
  const _BottomCircleIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xAA121212),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 5)),
              ],
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
