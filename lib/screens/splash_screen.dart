import 'package:flutter/material.dart';

import '../theme/arena_theme.dart';
import '../widgets/glossy.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..forward();

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 450),
            pageBuilder: (_, a, _) => FadeTransition(opacity: a, child: const HomeScreen()),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pop = CurvedAnimation(
      parent: _c,
      curve: const Interval(0, 0.55, curve: Curves.elasticOut),
    );
    final fade = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    );
    return ArenaScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FittedBox(fit: BoxFit.scaleDown, child: _content(pop, fade)),
        ),
      ),
    );
  }

  Widget _content(Animation<double> pop, Animation<double> fade) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: pop,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: const [
                BoxShadow(color: Color(0x99000000), blurRadius: 30, offset: Offset(0, 16)),
                BoxShadow(color: Color(0x40FF8A3D), blurRadius: 40),
              ],
            ),
            child: Image.asset('assets/branding/logo.png', width: 168, height: 168, semanticLabel: 'Sling Arena logo'),
          ),
        ),
        const SizedBox(height: 24),
        ScaleTransition(
          scale: pop,
          child: Text('SLING', style: Arena.display(64, outline: const Color(0xFFB4561C))),
        ),
        ScaleTransition(
          scale: pop,
          child: Text(
            'ARENA',
            style: Arena.display(64, color: Arena.gold, outline: const Color(0xFF8A4A0C)),
          ),
        ),
        const SizedBox(height: 16),
        FadeTransition(
          opacity: fade,
          child: Text('FLICK · SLIDE · CLEAR YOUR SIDE', style: Arena.label(12)),
        ),
      ],
    );
  }
}
