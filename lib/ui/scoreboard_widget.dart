import 'package:flutter/material.dart';

class ScoreboardWidget extends StatelessWidget {
  const ScoreboardWidget({
    super.key,
    required this.playerScore,
    required this.opponentScore,
    required this.playerName,
    required this.opponentName,
    this.playerPucks = 5,
    this.opponentPucks = 5,
    this.onMenuTap,
    this.onSoundTap,
    this.isSoundOn = true,
  });

  final int playerScore;
  final int opponentScore;
  final int playerPucks;
  final int opponentPucks;
  final String playerName;
  final String opponentName;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSoundTap;
  final bool isSoundOn;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 🔥 MAIN CARD
        Container(
          height: 115,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF1C1D20), Color(0xFF0D0E10)],
            ),
            border: Border.all(color: const Color(0x33FFFFFF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x88000000),
                blurRadius: 25,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: Color(0x33FF9F43),
                blurRadius: 20,
              ),
            ],
          ),

          child: Row(
            children: [
              /// 👤 PLAYER
              Expanded(
                child: _SideInfo(
                  label: playerName,
                  puckCount: playerPucks,
                  puckColor: const Color(0xFF39DFA8),
                  isActive: true,
                  avatar: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF39DFA8),
                    child: Icon(Icons.person,
                        color: Colors.black, size: 20),
                  ),
                  alignRight: false,
                ),
              ),

              /// 🎯 SCORE
              Expanded(
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.9, end: 1),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) =>
                        Transform.scale(scale: value, child: child),
                    child: Text(
                      '$playerScore  :  $opponentScore',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              /// 🤖 / 👥 OPPONENT
              Expanded(
                child: _SideInfo(
                  label: opponentName,
                  puckCount: opponentPucks,
                  puckColor: Colors.white,
                  isActive: false,
                  avatar: CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF2A2D31),
                    child: Icon(
                      opponentName.toLowerCase().contains('ai')
                          ? Icons.smart_toy
                          : Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  alignRight: true,
                ),
              ),
            ],
          ),
        ),

        /// ☰ MENU
        Positioned(
          left: 6,
          top: 6,
          child: _TopIconButton(
            icon: Icons.menu_rounded,
            onTap: onMenuTap,
          ),
        ),

        /// 🔊 SOUND
        Positioned(
          right: 6,
          top: 6,
          child: _TopIconButton(
            icon: isSoundOn
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
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
    required this.isActive,
  });

  final String label;
  final int puckCount;
  final Color puckColor;
  final Widget avatar;
  final bool alignRight;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final rowChildren = [
      avatar,
      const SizedBox(width: 8),
      Text(
        label.toUpperCase(),
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white60,
          fontWeight: FontWeight.w800,
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

        const SizedBox(height: 10),

        /// 🔥 PUCKS
        Row(
          mainAxisAlignment:
              alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: List.generate(
            5,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: index < puckCount
                    ? puckColor
                    : Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
                boxShadow: index < puckCount
                    ? [
                        BoxShadow(
                          color: puckColor.withOpacity(0.6),
                          blurRadius: 6,
                        )
                      ]
                    : [],
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
      onTapDown: (_) => setState(() => _scale = 0.88),
      onTapCancel: () => setState(() => _scale = 1),
      onTapUp: (_) => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2A2D31), Color(0xFF1A1B1D)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}