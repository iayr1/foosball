import 'package:flutter/material.dart';

import '../controllers/game_flow_controller.dart';
import '../models/game_mode.dart';
import 'tutorial_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key, required this.flowController});

  final GameFlowController flowController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071317),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Sling Puck',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 52),
                  _AnimatedTapButton(
                    label: 'Play with Friend',
                    icon: Icons.group,
                    onTap: () => _selectMode(context, GameMode.twoPlayer),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedTapButton(
                    label: 'Play with AI',
                    icon: Icons.smart_toy_outlined,
                    onTap: () => _selectMode(context, GameMode.vsAI),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectMode(BuildContext context, GameMode mode) {
    flowController.setMode(mode);
    Navigator.of(context).push(
      _slideRoute(
        TutorialScreen(flowController: flowController),
      ),
    );
  }
}

class _AnimatedTapButton extends StatefulWidget {
  const _AnimatedTapButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_AnimatedTapButton> createState() => _AnimatedTapButtonState();
}

class _AnimatedTapButtonState extends State<_AnimatedTapButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 130),
        scale: _pressed ? 0.97 : 1,
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF31D0AA), Color(0xFF1C8F78)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4431D0AA),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: const Color(0xFF06241E)),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Color(0xFF06241E),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Route<T> _slideRoute<T>(Widget child) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, __, ___) => child,
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween<Offset>(
        begin: const Offset(0.12, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
