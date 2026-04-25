import 'dart:math';
import 'package:flutter/material.dart';
import '../controllers/game_flow_controller.dart';
import 'mode_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.flowController});
  final GameFlowController flowController;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _masterCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _puckCtrl;
  late final AnimationController _particleCtrl;

  late final Animation<double> _fadeIn;
  late final Animation<double> _titleScale;
  late final Animation<Offset> _titleSlide;

  final List<_Particle> _particles = List.generate(40, (_) => _Particle());

  @override
  void initState() {
    super.initState();

    _masterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..forward();

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _puckCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);

    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat();

    _fadeIn = CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    _titleScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _masterCtrl, curve: const Interval(0.2, 0.8, curve: Curves.easeOut)),
    );

    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => ModeSelectionScreen(flowController: widget.flowController),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    _glowCtrl.dispose();
    _puckCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.4,
            colors: [Color(0xFF0D1A2E), Color(0xFF070B10), Color(0xFF030303)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Floating particles
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ParticlePainter(_particles, _particleCtrl.value),
                size: MediaQuery.of(context).size,
              ),
            ),
            // Scanline texture
            Opacity(
              opacity: 0.04,
              child: CustomPaint(
                painter: _ScanlinePainter(),
                size: MediaQuery.of(context).size,
              ),
            ),
            // Corner decorations
            ..._buildCornerDecors(),
            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ArenaWidget(puckCtrl: _puckCtrl, glowCtrl: _glowCtrl),
                    const SizedBox(height: 24),
                    SlideTransition(
                      position: _titleSlide,
                      child: ScaleTransition(
                        scale: _titleScale,
                        child: _TitleBlock(glowCtrl: _glowCtrl),
                      ),
                    ),
                    const SizedBox(height: 44),
                    _LoadingDots(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerDecors() {
    const size = 32.0;
    const color = Color(0x4D4A90D9);
    const strokeW = 1.5;
    return [
      Positioned(top: 36, left: 36, child: _CornerDecor(size: size, color: color, strokeWidth: strokeW, corner: Corner.topLeft)),
      Positioned(top: 36, right: 36, child: _CornerDecor(size: size, color: color, strokeWidth: strokeW, corner: Corner.topRight)),
      Positioned(bottom: 60, left: 36, child: _CornerDecor(size: size, color: color, strokeWidth: strokeW, corner: Corner.bottomLeft)),
      Positioned(bottom: 60, right: 36, child: _CornerDecor(size: size, color: color, strokeWidth: strokeW, corner: Corner.bottomRight)),
    ];
  }
}

// ─── Arena Widget ───────────────────────────────────────────────────────────

class _ArenaWidget extends StatelessWidget {
  const _ArenaWidget({required this.puckCtrl, required this.glowCtrl});
  final AnimationController puckCtrl;
  final AnimationController glowCtrl;

  @override
  Widget build(BuildContext context) {
    final puckAnim = CurvedAnimation(parent: puckCtrl, curve: Curves.easeInOut);

    return SizedBox(
      width: 300,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient glow behind arena
          AnimatedBuilder(
            animation: glowCtrl,
            builder: (_, __) => Container(
              width: 260,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color.lerp(
                      const Color(0x1A1E64C8),
                      const Color(0x2A3296FF),
                      glowCtrl.value,
                    )!,
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          // Arena table
          Container(
            width: 240,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x301A5C8C), width: 1.5),
              color: const Color(0x160A1423),
            ),
            child: Stack(
              children: [
                // Center line
                Center(
                  child: Container(
                    width: 1,
                    height: double.infinity,
                    color: const Color(0x303278DC),
                  ),
                ),
                // Center circle
                Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x203278DC)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Goals
          Positioned(
            left: 24,
            child: _Goal(isLeft: true),
          ),
          Positioned(
            right: 24,
            child: _Goal(isLeft: false),
          ),
          // Pucks
          AnimatedBuilder(
            animation: puckAnim,
            builder: (_, __) {
              final offset = Tween<double>(begin: -4, end: 4).evaluate(puckAnim);
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Elastic band - white puck
                  Positioned(
                    right: 108 - offset,
                    child: Container(
                      width: 32,
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0x005096FF), Color(0x995096FF)],
                        ),
                      ),
                    ),
                  ),
                  // Elastic band - black puck
                  Positioned(
                    left: 108 + offset,
                    child: Container(
                      width: 32,
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0x00FF6428), Color(0x80FF6428)],
                        ),
                      ),
                    ),
                  ),
                  // White puck
                  Positioned(
                    right: 56 - offset,
                    child: _Puck(isWhite: true),
                  ),
                  // Dark puck
                  Positioned(
                    left: 56 + offset,
                    child: _Puck(isWhite: false),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Goal extends StatelessWidget {
  const _Goal({required this.isLeft});
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isLeft
            ? const Color(0x4050A0FF)
            : const Color(0x33FF6428),
        border: Border.all(
          color: isLeft
              ? const Color(0x6650A0FF)
              : const Color(0x55FF6428),
        ),
        boxShadow: [
          BoxShadow(
            color: isLeft
                ? const Color(0x4450A0FF)
                : const Color(0x33FF6428),
            blurRadius: 14,
          ),
        ],
      ),
    );
  }
}

class _Puck extends StatelessWidget {
  const _Puck({required this.isWhite});
  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isWhite
            ? const RadialGradient(
                center: Alignment(-0.3, -0.3),
                colors: [Colors.white, Color(0xFFC8D8E8), Color(0xFF8AA8C0)],
              )
            : const RadialGradient(
                center: Alignment(-0.3, -0.3),
                colors: [Color(0xFF2A2A2A), Color(0xFF101010), Color(0xFF050505)],
              ),
        border: Border.all(
          color: isWhite
              ? Colors.white.withOpacity(0.9)
              : const Color(0xFF6432191).withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: isWhite
            ? [
                const BoxShadow(
                  color: Color(0xB2B4D0FF),
                  blurRadius: 18,
                ),
                const BoxShadow(
                  color: Color(0x5964A0FF),
                  blurRadius: 36,
                ),
              ]
            : [
                const BoxShadow(
                  color: Color(0x66FF5014),
                  blurRadius: 18,
                ),
                const BoxShadow(
                  color: Color(0x33DC3C0A),
                  blurRadius: 36,
                ),
              ],
      ),
    );
  }
}

// ─── Title Block ─────────────────────────────────────────────────────────────

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.glowCtrl});
  final AnimationController glowCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'THE ULTIMATE CHALLENGE',
          style: TextStyle(
            color: Color(0xB34A90D9),
            fontSize: 11,
            letterSpacing: 5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: glowCtrl,
          builder: (_, child) {
            final glow = Tween<double>(begin: 16, end: 32).evaluate(
              CurvedAnimation(parent: glowCtrl, curve: Curves.easeInOut),
            );
            return Text(
              'SLING\nPUCK',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w900,
                height: 0.95,
                letterSpacing: 3,
                shadows: [
                  Shadow(color: const Color(0x664896FF), blurRadius: glow),
                  Shadow(color: const Color(0x264896FF), blurRadius: glow * 2.5),
                  const Shadow(color: Color(0xFF0A1520), offset: Offset(0, 2)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Container(
          width: 180,
          height: 2,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Color(0x994896FF), Colors.transparent],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'FLICK  ·  SCORE  ·  WIN',
          style: TextStyle(
            color: Color(0x80A0BEDC),
            fontSize: 12,
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─── Loading Dots ────────────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3.0;
            final progress = ((_ctrl.value - delay) % 1.0 + 1.0) % 1.0;
            final scale = 1.0 + sin(progress * pi) * 0.6;
            final opacity = 0.3 + sin(progress * pi) * 0.7;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scaleY: scale,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4896FF),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─── Particles ───────────────────────────────────────────────────────────────

class _Particle {
  final Random _rng = Random();
  late double x, y, vx, vy, r, alpha;
  late Color color;

  _Particle() {
    _reset(Random().nextDouble());
  }

  void _reset(double progress) {
    x = _rng.nextDouble() * 400;
    y = 700 - _rng.nextDouble() * 700 * progress;
    vx = (_rng.nextDouble() - 0.5) * 0.4;
    vy = -(_rng.nextDouble() * 0.6 + 0.2);
    r = _rng.nextDouble() * 1.5 + 0.3;
    alpha = _rng.nextDouble() * 0.5 + 0.1;
    color = _rng.nextBool()
        ? const Color(0xFF3C78FF)
        : const Color(0xFFFF6428);
  }

  void update(Size size) {
    x += vx;
    y += vy;
    if (y < 0) _reset(0);
    if (x < 0 || x > size.width) vx *= -1;
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles, this.t);
  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      p.update(size);
      final paint = Paint()
        ..color = p.color.withOpacity(p.alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.r, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

// ─── Scanlines ───────────────────────────────────────────────────────────────

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

// ─── Corner Decor ────────────────────────────────────────────────────────────

enum Corner { topLeft, topRight, bottomLeft, bottomRight }

class _CornerDecor extends StatelessWidget {
  const _CornerDecor({
    required this.size,
    required this.color,
    required this.strokeWidth,
    required this.corner,
  });
  final double size;
  final Color color;
  final double strokeWidth;
  final Corner corner;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CornerPainter(color: color, strokeWidth: strokeWidth, corner: corner),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.corner,
  });
  final Color color;
  final double strokeWidth;
  final Corner corner;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final w = size.width;
    final h = size.height;

    switch (corner) {
      case Corner.topLeft:
        canvas.drawPath(Path()..moveTo(0, h)..lineTo(0, 0)..lineTo(w, 0), paint);
      case Corner.topRight:
        canvas.drawPath(Path()..moveTo(0, 0)..lineTo(w, 0)..lineTo(w, h), paint);
      case Corner.bottomLeft:
        canvas.drawPath(Path()..moveTo(0, 0)..lineTo(0, h)..lineTo(w, h), paint);
      case Corner.bottomRight:
        canvas.drawPath(Path()..moveTo(w, 0)..lineTo(w, h)..lineTo(0, h), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}