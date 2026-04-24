import 'dart:ui';

import 'package:flutter/material.dart';

class Scoreboard extends StatelessWidget {
  const Scoreboard({
    super.key,
    required this.score,
    this.onMenuTap,
    this.onSoundTap,
    this.isSoundOn = true,
  });

  final String score;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSoundTap;
  final bool isSoundOn;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: const Color(0x98121212),
                border: Border.all(color: Colors.white.withOpacity(0.14)),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 18, offset: Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const _PlayerBadge(label: 'YOU', isPlayer: true),
                      Expanded(
                        child: Center(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.85, end: 1),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) => Transform.scale(
                              scale: value,
                              child: child,
                            ),
                            child: Text(
                              score,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 30,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const _PlayerBadge(label: 'AI', isPlayer: false),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _PuckIndicators(isPlayer: true),
                      _PuckIndicators(isPlayer: false),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: _TopCircleIcon(icon: Icons.menu_rounded, onTap: onMenuTap),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _TopCircleIcon(
            icon: isSoundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            onTap: onSoundTap,
          ),
        ),
      ],
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  const _PlayerBadge({required this.label, required this.isPlayer});

  final String label;
  final bool isPlayer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: isPlayer ? const Color(0xFF3A8DFF) : const Color(0xFF7D5BFF),
          child: Icon(isPlayer ? Icons.person : Icons.smart_toy, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _PuckIndicators extends StatelessWidget {
  const _PuckIndicators({required this.isPlayer});

  final bool isPlayer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPlayer ? Colors.white : Colors.black,
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
        ),
      ),
    );
  }
}

class _TopCircleIcon extends StatelessWidget {
  const _TopCircleIcon({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xCC111111),
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
