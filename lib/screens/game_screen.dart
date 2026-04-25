import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_mode.dart';
import '../widgets/game_board.dart';
import '../widgets/scoreboard.dart';
import 'lose_screen.dart';
import 'pause_dialog.dart';
import 'win_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.mode});

  final GameMode mode;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  bool _soundOn = true;
  bool _showPause = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    // Lock portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF070B14),
              Color(0xFF0D1525),
              Color(0xFF111828),
              Color(0xFF0A0F1E),
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Subtle ice rink ambiance — radial glow at center
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _glowAnim,
                builder: (_, __) => CustomPaint(
                  painter: _AmbientGlowPainter(_glowAnim.value),
                ),
              ),
            ),

            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  10,
                  14,
                  bottomPadding + 10,
                ),
                child: Column(
                  children: [
                    // ── Scoreboard ──────────────────────────────────────
                    _StyledScoreboard(
                      score: '0 - 0',
                      isSoundOn: _soundOn,
                      onMenuTap: () => setState(() => _showPause = true),
                      onSoundTap: () => setState(() => _soundOn = !_soundOn),
                    ),

                    const SizedBox(height: 12),

                    // ── Game Board ───────────────────────────────────────
                    Expanded(
                      child: Center(
                        child: Container(
                          width: size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF1DE9FF).withOpacity(0.18),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1DE9FF).withOpacity(0.08),
                                blurRadius: 32,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: const GameBoard(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Action Row ───────────────────────────────────────
                    SizedBox(
                      height: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Undo
                          _CircleAction(
                            icon: Icons.undo_rounded,
                            label: 'Undo',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const LoseScreen()),
                            ),
                          ),

                          // Center hint
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _pulseAnim,
                                builder: (_, child) => Transform.scale(
                                  scale: _pulseAnim.value,
                                  child: child,
                                ),
                                child: const Text('☝️', style: TextStyle(fontSize: 22)),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Drag puck',
                                style: TextStyle(
                                  color: Color(0xFF8FA8C8),
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          // Power
                          _CircleAction(
                            icon: Icons.bolt_rounded,
                            label: 'Power',
                            highlight: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const WinScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Turn Banner ──────────────────────────────────────
                    _TurnBanner(glowAnim: _glowAnim),

                    SizedBox(height: bottomPadding > 0 ? 4 : 8),
                  ],
                ),
              ),
            ),

            // ── Pause Overlay ────────────────────────────────────────────
            if (_showPause)
              Container(
                color: Colors.black.withOpacity(0.72),
                child: PauseDialog(
                  onResume: () => setState(() => _showPause = false),
                  onRestart: () => setState(() => _showPause = false),
                  onMainMenu: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Styled Scoreboard Wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _StyledScoreboard extends StatelessWidget {
  const _StyledScoreboard({
    required this.score,
    required this.isSoundOn,
    required this.onMenuTap,
    required this.onSoundTap,
  });

  final String score;
  final bool isSoundOn;
  final VoidCallback onMenuTap;
  final VoidCallback onSoundTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1DE9FF).withOpacity(0.06),
            const Color(0xFF0D4F8C).withOpacity(0.08),
          ],
        ),
        border: Border.all(color: const Color(0xFF1DE9FF).withOpacity(0.12)),
      ),
      child: Scoreboard(
        score: score,
        isSoundOn: isSoundOn,
        onMenuTap: onMenuTap,
        onSoundTap: onSoundTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Turn Banner
// ─────────────────────────────────────────────────────────────────────────────

class _TurnBanner extends StatelessWidget {
  const _TurnBanner({required this.glowAnim});
  final Animation<double> glowAnim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (_, __) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0A2744).withOpacity(0.85),
              const Color(0xFF0D1E35).withOpacity(0.85),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF1DE9FF)
                .withOpacity(0.15 + 0.12 * glowAnim.value),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1DE9FF)
                  .withOpacity(0.04 + 0.06 * glowAnim.value),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1DE9FF),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1DE9FF)
                        .withOpacity(0.6 * glowAnim.value),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR TURN',
                  style: TextStyle(
                    color: const Color(0xFF1DE9FF)
                        .withOpacity(0.85 + 0.15 * glowAnim.value),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'Drag & release to shoot!',
                  style: TextStyle(
                    color: Color(0xFF7BA8C4),
                    fontSize: 11.5,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Circle Action Button
// ─────────────────────────────────────────────────────────────────────────────

class _CircleAction extends StatefulWidget {
  const _CircleAction({
    required this.icon,
    required this.label,
    this.highlight = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool highlight;
  final VoidCallback? onTap;

  @override
  State<_CircleAction> createState() => _CircleActionState();
}

class _CircleActionState extends State<_CircleAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapController;
  late final Animation<double> _tapAnim;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _tapAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _tapController.forward();
    await _tapController.reverse();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        widget.highlight ? const Color(0xFFFFC44D) : const Color(0xFF1DE9FF);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _tapAnim,
        builder: (_, child) =>
            Transform.scale(scale: _tapAnim.value, child: child),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withOpacity(0.14),
                    const Color(0xFF080E1C).withOpacity(0.92),
                  ],
                ),
                border: Border.all(color: accent.withOpacity(0.45), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.28),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(widget.icon, color: accent, size: 22),
            ),
            const SizedBox(height: 5),
            Text(
              widget.label,
              style: TextStyle(
                color: accent.withOpacity(0.75),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Ambient Glow Background Painter
// ─────────────────────────────────────────────────────────────────────────────

class _AmbientGlowPainter extends CustomPainter {
  _AmbientGlowPainter(this.intensity);
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    // Top-center blue glow (like a stadium light)
    final topGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1DE9FF).withOpacity(0.07 * intensity),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height * 0.08),
          radius: size.width * 0.7,
        ),
      );
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.08),
      size.width * 0.7,
      topGlow,
    );

    // Center ice glow
    final centerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0A3D6B).withOpacity(0.12 * intensity),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height * 0.45),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.45),
      size.width * 0.6,
      centerGlow,
    );

    // Bottom amber glow (warm court reflection)
    final bottomGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFC44D).withOpacity(0.05 * intensity),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height * 0.92),
          radius: size.width * 0.55,
        ),
      );
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.92),
      size.width * 0.55,
      bottomGlow,
    );
  }

  @override
  bool shouldRepaint(_AmbientGlowPainter old) => old.intensity != intensity;
}