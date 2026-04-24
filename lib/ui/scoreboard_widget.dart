import 'dart:ui';

import 'package:flutter/material.dart';

class ScoreboardWidget extends StatelessWidget {
  const ScoreboardWidget({
    super.key,
    required this.playerScore,
    required this.aiScore,
    this.playerPucks = 5,
    this.aiPucks = 5,
    this.onMenuTap,
    this.onSoundTap,
    this.isSoundOn = true,
  });

  final int playerScore;
  final int aiScore;
  final int playerPucks;
  final int aiPucks;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSoundTap;
  final bool isSoundOn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Container(
          height: 110,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xE61A1A1D), Color(0xB30E0E10)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Row(
                children: [
                  Expanded(
                    child: _SideInfo(
                      label: 'YOU',
                      puckCount: playerPucks,
                      puckColor: Colors.white,
                      avatar: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF39DFA8),
                        child: Icon(Icons.person, color: Colors.black, size: 18),
                      ),
                      alignRight: false,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) => Transform.scale(
                          scale: 0.95 + (value * 0.05),
                          child: child,
                        ),
                        child: Text(
                          '$playerScore - $aiScore',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _SideInfo(
                      label: 'AI',
                      puckCount: aiPucks,
                      puckColor: Colors.black,
                      avatar: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF2A2D31),
                        child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
                      ),
                      alignRight: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 4,
          top: 4,
          child: _TopIconButton(icon: Icons.menu_rounded, onTap: onMenuTap),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: _TopIconButton(
            icon: isSoundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            onTap: onSoundTap,
          ),
        ),
      ],
    );
  }
}

class _SideInfo extends StatelessWidget {
  const _SideInfo({
    required this.label,
    required this.puckCount,
    required this.puckColor,
    required this.avatar,
    required this.alignRight,
  });

  final String label;
  final int puckCount;
  final Color puckColor;
  final Widget avatar;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final rowChildren = [
      avatar,
      const SizedBox(width: 8),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment:
              alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: alignRight ? rowChildren.reversed.toList() : rowChildren,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment:
              alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: List.generate(
            5,
            (index) => Container(
              margin: const EdgeInsets.only(right: 4),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color:
                    index < puckCount ? puckColor : Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopIconButton extends StatefulWidget {
  const _TopIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<_TopIconButton> createState() => _TopIconButtonState();
}

class _TopIconButtonState extends State<_TopIconButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapCancel: () => setState(() => _scale = 1),
      onTapUp: (_) => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.32),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
