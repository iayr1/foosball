import 'package:flutter/material.dart';

import '../controllers/game_flow_controller.dart';
import '../models/game_mode.dart';
import '../widgets/custom_button.dart';
import '../ui/game_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key, required this.flowController});

  final GameFlowController flowController;

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startGame() {
    final mode = widget.flowController.selectedMode ?? GameMode.vsAI;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SlingPuckGameView(mode: mode),
        transitionDuration: const Duration(milliseconds: 420),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF111111), Color(0xFF1E130D)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Text(
                  'HOW TO PLAY',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _index ? const Color(0xFF42E38C) : Colors.white24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (value) => setState(() => _index = value),
                    children: const [
                      _TutorialCard(title: 'DRAG', symbol: '👆', text: 'Drag the puck backwards'),
                      _TutorialCard(title: 'AIM', symbol: '➶', text: 'Aim towards the gap'),
                      _TutorialCard(title: 'RELEASE', symbol: '💨', text: 'Release to shoot'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xAA131313),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• Shoot all pucks to opponent side', style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 4),
                      Text('• Only shoot from your area', style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 4),
                      Text('• First to clear wins', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                CustomButton(
                  title: 'GOT IT',
                  gradient: const LinearGradient(colors: [Color(0xFF38C975), Color(0xFF2C9D5D)]),
                  subtitle: 'Start match',
                  onTap: _startGame,
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                ),
                TextButton(
                  onPressed: _startGame,
                  child: const Text('SKIP TUTORIAL', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TutorialCard extends StatelessWidget {
  const _TutorialCard({required this.title, required this.symbol, required this.text});

  final String title;
  final String symbol;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x771B1B1B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Text(symbol, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 14),
            Text(text, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
