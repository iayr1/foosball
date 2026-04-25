import 'package:flutter/material.dart';
import '../controllers/game_flow_controller.dart';
import '../models/game_mode.dart';
import 'mode_bottom_screens.dart';
import 'tutorial_screen.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key, required this.flowController});
  final GameFlowController flowController;

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final hPad = size.width * 0.062;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.7),
            radius: 1.6,
            colors: [Color(0xFF0D1828), Color(0xFF060A10), Color(0xFF030507)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Ambient orbs
            Positioned(
              top: 40,
              left: -60,
              child: _AmbientOrb(
                size: size.width * 0.55,
                color: const Color(0x1414509E),
              ),
            ),
            Positioned(
              top: size.height * 0.34,
              right: -50,
              child: _AmbientOrb(
                size: size.width * 0.48,
                color: const Color(0x0F6428C8),
              ),
            ),
            // Scanlines
            Opacity(
              opacity: 0.03,
              child: CustomPaint(
                painter: _ScanlinePainter(),
                size: size,
              ),
            ),
            // Content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      SizedBox(height: isSmall ? 16 : 28),
                      _Header(isSmall: isSmall),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SectionLabel(text: 'SELECT MODE'),
                              SizedBox(height: isSmall ? 12 : 18),
                              _ModeCard(
                                title: '2 PLAYER',
                                subtitle: 'Face off on the same device',
                                icon: Icons.group_rounded,
                                accentColor: const Color(0xFF4A90FF),
                                gradientColors: const [
                                  Color(0xFF1A3A6E),
                                  Color(0xFF0F2248),
                                  Color(0xFF091830),
                                ],
                                borderColor: const Color(0x4D4A90FF),
                                onTap: () => _goTutorial(context, GameMode.twoPlayer),
                              ),
                              SizedBox(height: isSmall ? 12 : 16),
                              _ModeCard(
                                title: 'VS AI',
                                subtitle: 'Challenge the machine',
                                icon: Icons.smart_toy_rounded,
                                accentColor: const Color(0xFF9060FF),
                                gradientColors: const [
                                  Color(0xFF2A1A5E),
                                  Color(0xFF1A0F48),
                                  Color(0xFF100930),
                                ],
                                borderColor: const Color(0x4D8C5AFF),
                                badge: 'POPULAR',
                                onTap: () => _goTutorial(context, GameMode.vsAI),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: hPad,
                          vertical: isSmall ? 12 : 20,
                        ),
                        child: _BottomNavBar(
                          onAcademy: () => _openScreen(context, const AcademyScreen()),
                          onAchievements: () => _openScreen(context, const AchievementsScreen()),
                          onStore: () => _openScreen(context, const StoreScreen()),
                          onSettings: () => _openScreen(context, const SettingsScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goTutorial(BuildContext context, GameMode mode) {
    widget.flowController.setMode(mode);
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, __, ___) =>
          TutorialScreen(flowController: widget.flowController),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ));
  }

  void _openScreen(BuildContext context, Widget child) {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (_, anim, __, page) =>
          FadeTransition(opacity: anim, child: page),
    ));
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.isSmall});
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Rank pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0x1AFFB41E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x40FFB41E)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.star_rounded, color: Color(0xFFFFB41E), size: 14),
              SizedBox(width: 6),
              Text(
                'RANK: GOLD III',
                style: TextStyle(
                  color: Color(0xFFFFB41E),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isSmall ? 10 : 14),
        // Title
        Text(
          'SLING\nPUCK',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmall ? 44 : 52,
            fontWeight: FontWeight.w900,
            height: 0.92,
            letterSpacing: 2,
            shadows: const [
              Shadow(color: Color(0x594682FF), blurRadius: 36),
              Shadow(color: Color(0xFF050810), offset: Offset(0, 2)),
            ],
          ),
        ),
        SizedBox(height: isSmall ? 6 : 8),
        const Text(
          'CHOOSE YOUR BATTLE',
          style: TextStyle(
            color: Color(0x806496DC),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
          ),
        ),
        SizedBox(height: isSmall ? 8 : 12),
        Container(
          width: 60,
          height: 1.5,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Color(0x804682FF), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0x4D5080B4),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 4,
      ),
    );
  }
}

// ─── Mode Card ───────────────────────────────────────────────────────────────

class _ModeCard extends StatefulWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
    required this.borderColor,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;
  final Color borderColor;
  final VoidCallback onTap;
  final String? badge;

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.025,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.975).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: const Alignment(-1, -1),
              end: const Alignment(1, 1),
              colors: widget.gradientColors,
            ),
            border: Border.all(color: widget.borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.18),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Top shine
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  // Icon box
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: widget.accentColor.withOpacity(0.15),
                      border: Border.all(
                        color: widget.accentColor.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.accentColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentColor.withOpacity(0.15),
                      border: Border.all(
                        color: widget.accentColor.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: widget.accentColor,
                      size: 16,
                    ),
                  ),
                ],
              ),
              // Badge
              if (widget.badge != null)
                Positioned(
                  top: 0,
                  right: 42,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x26FFB41E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x4DFFB41E)),
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        color: Color(0xFFFFB41E),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
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

// ─── Bottom Nav Bar ───────────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.onAcademy,
    required this.onAchievements,
    required this.onStore,
    required this.onSettings,
  });

  final VoidCallback onAcademy;
  final VoidCallback onAchievements;
  final VoidCallback onStore;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xCC0A1018),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.school_rounded,
            label: 'ACADEMY',
            onTap: onAcademy,
          ),
          _NavItem(
            icon: Icons.emoji_events_rounded,
            label: 'AWARDS',
            onTap: onAchievements,
          ),
          _NavItem(
            icon: Icons.store_rounded,
            label: 'STORE',
            onTap: onStore,
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'PROFILE',
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _pressed
              ? const Color(0x194A90FF)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              color: _pressed
                  ? const Color(0xFF6AA4DC)
                  : const Color(0x806494CC),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                color: _pressed
                    ? const Color(0xFF6AA4DC)
                    : const Color(0x996494CC),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          // Use MaskFilter for blur effect
        ),
      ),
    );
  }
}

// Use this instead for the blur orbs:
class _BlurOrb extends StatelessWidget {
  const _BlurOrb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}