import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/game_flow_controller.dart';
import '../models/game_mode.dart';
import '../ui/game_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key, required this.flowController});
  final GameFlowController flowController;

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _index = 0;

  late final AnimationController _entryCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _startGame() {
    final mode = widget.flowController.selectedMode ?? GameMode.vsAI;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => SlingPuckGameView(mode: mode),
      transitionDuration: const Duration(milliseconds: 450),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final hPad = size.width * 0.052;

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
            Positioned(
              top: size.height * 0.25,
              left: -80,
              child: _BlurOrb(size: size.width * 0.58, color: const Color(0x0F14B464)),
            ),
            Positioned(
              bottom: size.height * 0.2,
              right: -60,
              child: _BlurOrb(size: size.width * 0.48, color: const Color(0x0F4682FF)),
            ),
            Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: _ScanlinePainter(), size: size),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      SizedBox(height: isSmall ? 12 : 20),
                      _TutorialHeader(
                        index: _index,
                        total: 3,
                        isSmall: isSmall,
                        hPad: hPad,
                      ),
                      SizedBox(height: isSmall ? 10 : 14),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (v) => setState(() => _index = v),
                            children: const [
                              _TutorialCard(
                                stepNum: '01',
                                title: 'DRAG',
                                description: 'Pull your puck backwards\nto load the elastic',
                                phase: 0.0,
                                accentColor: Color(0xFF32DC82),
                                iconPath: 'drag',
                              ),
                              _TutorialCard(
                                stepNum: '02',
                                title: 'AIM',
                                description: 'Angle toward the gap\nin the opponent\'s row',
                                phase: 0.33,
                                accentColor: Color(0xFF32DC82),
                                iconPath: 'aim',
                              ),
                              _TutorialCard(
                                stepNum: '03',
                                title: 'RELEASE',
                                description: 'Let go — the puck flies\nacross the board!',
                                phase: 0.66,
                                accentColor: Color(0xFF32DC82),
                                iconPath: 'release',
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: isSmall ? 10 : 14),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: const _RulesBlock(),
                      ),
                      SizedBox(height: isSmall ? 10 : 14),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: _StartButton(onTap: _startGame),
                      ),
                      GestureDetector(
                        onTap: _startGame,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 8,
                            bottom: isSmall ? 12 : 20,
                          ),
                          child: const Text(
                            'SKIP TUTORIAL',
                            style: TextStyle(
                              color: Color(0x607882BE),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
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
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _TutorialHeader extends StatelessWidget {
  const _TutorialHeader({
    required this.index,
    required this.total,
    required this.isSmall,
    required this.hPad,
  });

  final int index;
  final int total;
  final bool isSmall;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        children: [
          // Back row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Color(0x80FFFFFF),
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'STEP ${index + 1} OF $total',
                    style: const TextStyle(
                      color: Color(0x4D5080B4),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),
          SizedBox(height: isSmall ? 12 : 18),
          // Title
          Text(
            'HOW TO PLAY',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 32 : 38,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              shadows: const [
                Shadow(color: Color(0x4014DC64), blurRadius: 36),
                Shadow(color: Color(0xFF050810), offset: Offset(0, 2)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'MASTER THE SLING',
            style: TextStyle(
              color: Color(0x7232DC82),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 60,
            height: 1.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Color(0x8032DC82), Colors.transparent],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Page dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(total, (i) {
              final isActive = i == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                width: isActive ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? const Color(0xFF32DC82)
                      : Colors.white.withOpacity(0.12),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Tutorial Card ────────────────────────────────────────────────────────────

class _TutorialCard extends StatefulWidget {
  const _TutorialCard({
    required this.stepNum,
    required this.title,
    required this.description,
    required this.phase,
    required this.accentColor,
    required this.iconPath,
  });

  final String stepNum;
  final String title;
  final String description;
  final double phase;
  final Color accentColor;
  final String iconPath;

  @override
  State<_TutorialCard> createState() => _TutorialCardState();
}

class _TutorialCardState extends State<_TutorialCard>
    with TickerProviderStateMixin {
  late final AnimationController _puckCtrl;
  late final AnimationController _impactCtrl;
  late final Animation<double> _impactScale;
  late final Animation<double> _impactOpacity;

  @override
  void initState() {
    super.initState();

    _puckCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _impactCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _impactScale = Tween<double>(begin: 0.4, end: 2.2).animate(
      CurvedAnimation(parent: _impactCtrl, curve: Curves.easeOut),
    );
    _impactOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _impactCtrl, curve: Curves.easeOut),
    );

    _puckCtrl.addListener(() {
      final adjusted = (_puckCtrl.value + widget.phase) % 1.0;
      if (adjusted > 0.92) {
        if (!_impactCtrl.isAnimating) {
          _impactCtrl.forward(from: 0);
          HapticFeedback.lightImpact();
        }
      }
    });
  }

  @override
  void dispose() {
    _puckCtrl.dispose();
    _impactCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment(-1, -1),
          end: Alignment(1, 1),
          colors: [Color(0xFF121820), Color(0xFF0C1018)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withOpacity(0.06),
            blurRadius: 30,
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
                    Colors.white.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Step number
                Text(
                  'STEP ${widget.stepNum}',
                  style: TextStyle(
                    color: widget.accentColor.withOpacity(0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 6),
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: widget.accentColor.withOpacity(0.1),
                    border: Border.all(color: widget.accentColor.withOpacity(0.2)),
                  ),
                  child: Icon(
                    widget.iconPath == 'drag'
                        ? Icons.touch_app_rounded
                        : widget.iconPath == 'aim'
                            ? Icons.my_location_rounded
                            : Icons.send_rounded,
                    color: widget.accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                // Arena
                Expanded(
                  child: _AnimatedArena(
                    puckCtrl: _puckCtrl,
                    impactCtrl: _impactCtrl,
                    impactScale: _impactScale,
                    impactOpacity: _impactOpacity,
                    phase: widget.phase,
                    accentColor: widget.accentColor,
                  ),
                ),
                const SizedBox(height: 10),
                // Description
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Arena ───────────────────────────────────────────────────────────

class _AnimatedArena extends StatelessWidget {
  const _AnimatedArena({
    required this.puckCtrl,
    required this.impactCtrl,
    required this.impactScale,
    required this.impactOpacity,
    required this.phase,
    required this.accentColor,
  });

  final AnimationController puckCtrl;
  final AnimationController impactCtrl;
  final Animation<double> impactScale;
  final Animation<double> impactOpacity;
  final double phase;
  final Color accentColor;

  Offset _bezierPoint(double t, Size size) {
    const startFrac = 0.22;
    final p0 = Offset(startFrac * size.width, size.height * 0.72);
    final p1 = Offset(size.width * 0.55, size.height * 0.18);
    final p2 = Offset(size.width * 0.88, size.height * 0.5);
    return Offset(
      (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx,
      (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          children: [
            // Arena background
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0x160A1423),
                border: Border.all(color: const Color(0x201A5C8C)),
              ),
              child: Stack(
                children: [
                  // Center line
                  Center(
                    child: Container(
                      width: 1,
                      height: double.infinity,
                      color: const Color(0x203278DC),
                    ),
                  ),
                  // Center circle
                  Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x183278DC)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Goals
            Positioned(
              left: 0,
              top: size.height * 0.5 - 18,
              child: _Goal(isLeft: true),
            ),
            Positioned(
              right: 0,
              top: size.height * 0.5 - 18,
              child: _Goal(isLeft: false),
            ),
            // Trajectory + Puck
            AnimatedBuilder(
              animation: puckCtrl,
              builder: (_, __) {
                final t = ((puckCtrl.value + phase) % 1.0);
                final pos = _bezierPoint(t, size);
                return Stack(
                  children: [
                    // Dashed trajectory
                    CustomPaint(
                      size: size,
                      painter: _TrajPainter(
                        progress: t,
                        phase: phase,
                        accentColor: accentColor,
                      ),
                    ),
                    // Puck
                    Positioned(
                      left: pos.dx - 11,
                      top: pos.dy - 11,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            center: Alignment(-0.3, -0.3),
                            colors: [Colors.white, Color(0xFFC0D0E0), Color(0xFF8098B0)],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.9),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.5),
                              blurRadius: 12,
                            ),
                            BoxShadow(
                              color: const Color(0xFF4A90FF).withOpacity(0.3),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            // Impact burst
            AnimatedBuilder(
              animation: impactCtrl,
              builder: (_, __) {
                final end = _bezierPoint(1.0, size);
                return Positioned(
                  left: end.dx - 15,
                  top: end.dy - 15,
                  child: Opacity(
                    opacity: impactOpacity.value,
                    child: Transform.scale(
                      scale: impactScale.value,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _Goal extends StatelessWidget {
  const _Goal({required this.isLeft});
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isLeft ? const Color(0x4050A0FF) : const Color(0x33FF6428),
        border: Border.all(
          color: isLeft ? const Color(0x6650A0FF) : const Color(0x55FF6428),
        ),
        boxShadow: [
          BoxShadow(
            color: isLeft ? const Color(0x4450A0FF) : const Color(0x33FF6428),
            blurRadius: 12,
          ),
        ],
      ),
    );
  }
}

// ─── Trajectory Painter ───────────────────────────────────────────────────────

class _TrajPainter extends CustomPainter {
  const _TrajPainter({
    required this.progress,
    required this.phase,
    required this.accentColor,
  });

  final double progress;
  final double phase;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    const startFrac = 0.22;
    final p0 = Offset(startFrac * size.width, size.height * 0.72);
    final p1 = Offset(size.width * 0.55, size.height * 0.18);
    final p2 = Offset(size.width * 0.88, size.height * 0.5);

    final paint = Paint()
      ..color = accentColor.withOpacity(0.22)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool first = true;
    for (double t = 0; t <= progress; t += 0.02) {
      final x = (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx;
      final y = (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy;
      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(_TrajPainter old) =>
      old.progress != progress;
}

// ─── Rules Block ─────────────────────────────────────────────────────────────

class _RulesBlock extends StatelessWidget {
  const _RulesBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xCC0A121E),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RULES',
            style: TextStyle(
              color: Color(0x4D5080B4),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 10),
          ...[
            'Shoot all pucks to opponent\'s side',
            'Only shoot from your half',
            'First to clear their side wins',
          ].map((rule) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xB332DC82),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      rule,
                      style: const TextStyle(
                        color: Color(0x99A0BEDC),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Start Button ─────────────────────────────────────────────────────────────

class _StartButton extends StatefulWidget {
  const _StartButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
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
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment(-1, -1),
              end: Alignment(1, 1),
              colors: [Color(0xFF1A5E38), Color(0xFF0F3D24), Color(0xFF092418)],
            ),
            border: Border.all(color: const Color(0x4D32DC82)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2E1EB464),
                blurRadius: 28,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
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
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0x2632DC82),
                      border: Border.all(color: const Color(0x4032DC82)),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF32DC82),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GOT IT — PLAY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'START MATCH',
                          style: TextStyle(
                            color: Color(0x8032DC82),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x2032DC82),
                      border: Border.all(color: const Color(0x4032DC82)),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF32DC82),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

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