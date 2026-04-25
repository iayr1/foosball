import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_mode.dart';
import '../widgets/game_board.dart';
import '../widgets/scoreboard.dart';
import 'lose_screen.dart';
import 'pause_dialog.dart';
import 'win_screen.dart';

/// Breakpoints
class _BP {
  static const double mobile = 600;
  static const double tablet = 1024;
}

/// Layout configuration resolved per screen size
class _Layout {
  const _Layout({
    required this.isDesktop,
    required this.isTablet,
    required this.isMobile,
    required this.boardMaxWidth,
    required this.boardMaxHeight,
    required this.horizontalPad,
    required this.topPad,
    required this.actionBarHeight,
    required this.circleButtonSize,
    required this.circleIconSize,
    required this.labelFontSize,
    required this.turnBannerFontSize,
    required this.turnBannerSubFontSize,
    required this.hintFontSize,
    required this.hintEmoji,
    required this.scoreboardPadH,
    required this.scoreboardPadV,
    required this.isLandscape,
  });

  final bool isDesktop;
  final bool isTablet;
  final bool isMobile;
  final double boardMaxWidth;
  final double boardMaxHeight;
  final double horizontalPad;
  final double topPad;
  final double actionBarHeight;
  final double circleButtonSize;
  final double circleIconSize;
  final double labelFontSize;
  final double turnBannerFontSize;
  final double turnBannerSubFontSize;
  final double hintFontSize;
  final String hintEmoji;
  final double scoreboardPadH;
  final double scoreboardPadV;
  final bool isLandscape;

  factory _Layout.of(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final landscape = w > h;

    if (w >= _BP.tablet) {
      // ── Desktop / large tablet ────────────────────────────────
      return _Layout(
        isDesktop: true,
        isTablet: false,
        isMobile: false,
        boardMaxWidth: landscape ? h * 0.7 : w * 0.54,
        boardMaxHeight: landscape ? h * 0.78 : h * 0.62,
        horizontalPad: 32,
        topPad: 20,
        actionBarHeight: 100,
        circleButtonSize: 68,
        circleIconSize: 28,
        labelFontSize: 13,
        turnBannerFontSize: 15,
        turnBannerSubFontSize: 13,
        hintFontSize: 28,
        hintEmoji: '☝️',
        scoreboardPadH: 12,
        scoreboardPadV: 6,
        isLandscape: landscape,
      );
    } else if (w >= _BP.mobile) {
      // ── Tablet ────────────────────────────────────────────────
      return _Layout(
        isDesktop: false,
        isTablet: true,
        isMobile: false,
        boardMaxWidth: landscape ? h * 0.65 : w * 0.78,
        boardMaxHeight: landscape ? h * 0.72 : h * 0.58,
        horizontalPad: 24,
        topPad: 14,
        actionBarHeight: 90,
        circleButtonSize: 60,
        circleIconSize: 25,
        labelFontSize: 12,
        turnBannerFontSize: 14,
        turnBannerSubFontSize: 12,
        hintFontSize: 24,
        hintEmoji: '☝️',
        scoreboardPadH: 8,
        scoreboardPadV: 4,
        isLandscape: landscape,
      );
    } else {
      // ── Mobile ────────────────────────────────────────────────
      return _Layout(
        isDesktop: false,
        isTablet: false,
        isMobile: true,
        boardMaxWidth: w,
        boardMaxHeight: double.infinity,
        horizontalPad: 14,
        topPad: 10,
        actionBarHeight: 80,
        circleButtonSize: 54,
        circleIconSize: 22,
        labelFontSize: 11,
        turnBannerFontSize: 13,
        turnBannerSubFontSize: 11.5,
        hintFontSize: 22,
        hintEmoji: '☝️',
        scoreboardPadH: 4,
        scoreboardPadV: 2,
        isLandscape: landscape,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

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
    _applyOrientationPolicy();

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

  void _applyOrientationPolicy() {
    final w = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    if (w < _BP.mobile) {
      // Mobile: portrait only
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      // Tablet / desktop: all orientations allowed
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
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
    final layout = _Layout.of(context);
    final mq = MediaQuery.of(context);
    final bottomPadding = mq.padding.bottom;

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
            // Ambient glow background
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
                  layout.horizontalPad,
                  layout.topPad,
                  layout.horizontalPad,
                  bottomPadding + 10,
                ),
                child: layout.isLandscape && !layout.isMobile
                    ? _LandscapeLayout(
                        layout: layout,
                        soundOn: _soundOn,
                        pulseAnim: _pulseAnim,
                        glowAnim: _glowAnim,
                        bottomPadding: bottomPadding,
                        onMenuTap: () => setState(() => _showPause = true),
                        onSoundTap: () => setState(() => _soundOn = !_soundOn),
                        onUndoTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoseScreen()),
                        ),
                        onPowerTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const WinScreen()),
                        ),
                      )
                    : _PortraitLayout(
                        layout: layout,
                        soundOn: _soundOn,
                        pulseAnim: _pulseAnim,
                        glowAnim: _glowAnim,
                        bottomPadding: bottomPadding,
                        onMenuTap: () => setState(() => _showPause = true),
                        onSoundTap: () => setState(() => _soundOn = !_soundOn),
                        onUndoTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoseScreen()),
                        ),
                        onPowerTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const WinScreen()),
                        ),
                      ),
              ),
            ),

            // Pause Overlay
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
//  Portrait Layout (Mobile + Tablet portrait + Desktop portrait)
// ─────────────────────────────────────────────────────────────────────────────

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({
    required this.layout,
    required this.soundOn,
    required this.pulseAnim,
    required this.glowAnim,
    required this.bottomPadding,
    required this.onMenuTap,
    required this.onSoundTap,
    required this.onUndoTap,
    required this.onPowerTap,
  });

  final _Layout layout;
  final bool soundOn;
  final Animation<double> pulseAnim;
  final Animation<double> glowAnim;
  final double bottomPadding;
  final VoidCallback onMenuTap;
  final VoidCallback onSoundTap;
  final VoidCallback onUndoTap;
  final VoidCallback onPowerTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scoreboard
        _StyledScoreboard(
          score: '0 - 0',
          isSoundOn: soundOn,
          padH: layout.scoreboardPadH,
          padV: layout.scoreboardPadV,
          onMenuTap: onMenuTap,
          onSoundTap: onSoundTap,
        ),

        SizedBox(height: layout.isMobile ? 12 : 16),

        // Game Board
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: layout.boardMaxWidth,
                maxHeight: layout.boardMaxHeight,
              ),
              child: _BoardContainer(),
            ),
          ),
        ),

        SizedBox(height: layout.isMobile ? 10 : 14),

        // Action Row
        SizedBox(
          height: layout.actionBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CircleAction(
                icon: Icons.undo_rounded,
                label: 'Undo',
                size: layout.circleButtonSize,
                iconSize: layout.circleIconSize,
                labelFontSize: layout.labelFontSize,
                onTap: onUndoTap,
              ),
              _HintWidget(
                pulseAnim: pulseAnim,
                emoji: layout.hintEmoji,
                emojiFontSize: layout.hintFontSize,
                labelFontSize: layout.labelFontSize,
              ),
              _CircleAction(
                icon: Icons.bolt_rounded,
                label: 'Power',
                highlight: true,
                size: layout.circleButtonSize,
                iconSize: layout.circleIconSize,
                labelFontSize: layout.labelFontSize,
                onTap: onPowerTap,
              ),
            ],
          ),
        ),

        SizedBox(height: layout.isMobile ? 8 : 12),

        // Turn Banner
        _TurnBanner(
          glowAnim: glowAnim,
          titleFontSize: layout.turnBannerFontSize,
          subFontSize: layout.turnBannerSubFontSize,
        ),

        SizedBox(height: bottomPadding > 0 ? 4 : 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Landscape Layout (Tablet/Desktop landscape)
// ─────────────────────────────────────────────────────────────────────────────

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({
    required this.layout,
    required this.soundOn,
    required this.pulseAnim,
    required this.glowAnim,
    required this.bottomPadding,
    required this.onMenuTap,
    required this.onSoundTap,
    required this.onUndoTap,
    required this.onPowerTap,
  });

  final _Layout layout;
  final bool soundOn;
  final Animation<double> pulseAnim;
  final Animation<double> glowAnim;
  final double bottomPadding;
  final VoidCallback onMenuTap;
  final VoidCallback onSoundTap;
  final VoidCallback onUndoTap;
  final VoidCallback onPowerTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top scoreboard spanning full width
        _StyledScoreboard(
          score: '0 - 0',
          isSoundOn: soundOn,
          padH: layout.scoreboardPadH,
          padV: layout.scoreboardPadV,
          onMenuTap: onMenuTap,
          onSoundTap: onSoundTap,
        ),

        SizedBox(height: layout.isDesktop ? 14 : 10),

        // Main content: board on left, controls on right
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Game Board
              Expanded(
                flex: 6,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: layout.boardMaxWidth,
                      maxHeight: layout.boardMaxHeight,
                    ),
                    child: _BoardContainer(),
                  ),
                ),
              ),

              SizedBox(width: layout.isDesktop ? 24 : 16),

              // Right panel: actions + turn banner
              SizedBox(
                width: layout.isDesktop ? 200 : 160,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TurnBanner(
                      glowAnim: glowAnim,
                      titleFontSize: layout.turnBannerFontSize,
                      subFontSize: layout.turnBannerSubFontSize,
                    ),

                    SizedBox(height: layout.isDesktop ? 24 : 16),

                    _HintWidget(
                      pulseAnim: pulseAnim,
                      emoji: layout.hintEmoji,
                      emojiFontSize: layout.hintFontSize,
                      labelFontSize: layout.labelFontSize,
                    ),

                    SizedBox(height: layout.isDesktop ? 24 : 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CircleAction(
                          icon: Icons.undo_rounded,
                          label: 'Undo',
                          size: layout.circleButtonSize,
                          iconSize: layout.circleIconSize,
                          labelFontSize: layout.labelFontSize,
                          onTap: onUndoTap,
                        ),
                        _CircleAction(
                          icon: Icons.bolt_rounded,
                          label: 'Power',
                          highlight: true,
                          size: layout.circleButtonSize,
                          iconSize: layout.circleIconSize,
                          labelFontSize: layout.labelFontSize,
                          onTap: onPowerTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: bottomPadding > 0 ? 4 : 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Board Container
// ─────────────────────────────────────────────────────────────────────────────

class _BoardContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Hint Widget
// ─────────────────────────────────────────────────────────────────────────────

class _HintWidget extends StatelessWidget {
  const _HintWidget({
    required this.pulseAnim,
    required this.emoji,
    required this.emojiFontSize,
    required this.labelFontSize,
  });

  final Animation<double> pulseAnim;
  final String emoji;
  final double emojiFontSize;
  final double labelFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: pulseAnim,
          builder: (_, child) => Transform.scale(
            scale: pulseAnim.value,
            child: child,
          ),
          child: Text(emoji, style: TextStyle(fontSize: emojiFontSize)),
        ),
        const SizedBox(height: 3),
        Text(
          'Drag puck',
          style: TextStyle(
            color: const Color(0xFF8FA8C8),
            fontSize: labelFontSize,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
    required this.padH,
    required this.padV,
    required this.onMenuTap,
    required this.onSoundTap,
  });

  final String score;
  final bool isSoundOn;
  final double padH;
  final double padV;
  final VoidCallback onMenuTap;
  final VoidCallback onSoundTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
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
  const _TurnBanner({
    required this.glowAnim,
    required this.titleFontSize,
    required this.subFontSize,
  });

  final Animation<double> glowAnim;
  final double titleFontSize;
  final double subFontSize;

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
                    fontSize: titleFontSize,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Drag & release to shoot!',
                  style: TextStyle(
                    color: const Color(0xFF7BA8C4),
                    fontSize: subFontSize,
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
    required this.size,
    required this.iconSize,
    required this.labelFontSize,
    this.highlight = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final double size;
  final double iconSize;
  final double labelFontSize;
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
              width: widget.size,
              height: widget.size,
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
              child: Icon(widget.icon, color: accent, size: widget.iconSize),
            ),
            const SizedBox(height: 5),
            Text(
              widget.label,
              style: TextStyle(
                color: accent.withOpacity(0.75),
                fontSize: widget.labelFontSize,
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