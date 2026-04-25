import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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



class _TutorialCard extends StatefulWidget {
  const _TutorialCard({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  State<_TutorialCard> createState() => _TutorialCardState();
}

class _TutorialCardState extends State<_TutorialCard>
    with TickerProviderStateMixin {
  late AnimationController _puckController;
  late AnimationController _impactController;

  late Animation<Offset> _puckMove;
  late Animation<double> _impactScale;
  late Animation<double> _impactOpacity;

  @override
  void initState() {
    super.initState();

    /// 🎯 PUCK MOVEMENT (trajectory)
    _puckController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _puckMove = Tween<Offset>(
      begin: const Offset(-0.8, 0.5),
      end: const Offset(0.8, -0.2),
    ).animate(CurvedAnimation(
      parent: _puckController,
      curve: Curves.easeInOut,
    ));

    /// 💥 IMPACT
    _impactController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _impactScale = Tween<double>(begin: 0.5, end: 2).animate(
      CurvedAnimation(parent: _impactController, curve: Curves.easeOut),
    );

    _impactOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _impactController, curve: Curves.easeOut),
    );

    _puckController.addListener(() {
      if (_puckController.value > 0.95) {
        _impactController.forward(from: 0);

        /// 🔊 SOUND
        SystemSound.play(SystemSoundType.click);
      }
    });
  }

  @override
  void dispose() {
    _puckController.dispose();
    _impactController.dispose();
    super.dispose();
  }

  /// 🎯 TRAJECTORY LINE
  Widget _trajectory() {
    return CustomPaint(
      size: const Size(double.infinity, 150),
      painter: _TrajectoryPainter(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1B1D), Color(0xFF0E0F11)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🔥 TITLE
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 20),

            /// 🎯 TRAJECTORY
            _trajectory(),

            /// 🎮 PUCK + HAND
            SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// ✋ HAND
                  AnimatedBuilder(
                    animation: _puckController,
                    builder: (_, __) {
                      return Transform.translate(
                        offset: Offset(
                          _puckMove.value.dx * 120,
                          _puckMove.value.dy * 80,
                        ),
                        child: const Icon(
                          Icons.pan_tool_alt_rounded,
                          color: Colors.white70,
                          size: 32,
                        ),
                      );
                    },
                  ),

                  /// ⚪ PUCK
                  AnimatedBuilder(
                    animation: _puckController,
                    builder: (_, __) {
                      return Transform.translate(
                        offset: Offset(
                          _puckMove.value.dx * 120,
                          _puckMove.value.dy * 80,
                        ),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),

                  /// 💥 IMPACT
                  AnimatedBuilder(
                    animation: _impactController,
                    builder: (_, __) {
                      return Opacity(
                        opacity: _impactOpacity.value,
                        child: Transform.scale(
                          scale: _impactScale.value,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.orangeAccent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 📖 TEXT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🎯 TRAJECTORY PAINTER
class _TrajectoryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);

    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width,
      size.height * 0.5,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}