import 'dart:math';

import 'package:flutter/material.dart';

class GameBoardWidget extends StatelessWidget {
  const GameBoardWidget({
    super.key,
    this.highlightGap = true,
    this.gameLayer,
  });

  final bool highlightGap;

  /// Optional interactive game renderer layered on top of the board art.
  final Widget? gameLayer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1DE9FF).withOpacity(0.12),
                blurRadius: 32,
                spreadRadius: 4,
              ),
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 30,
                spreadRadius: 3,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _IceBoardPainter(highlightGap: highlightGap),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  if (gameLayer == null) ...[
                    ..._buildPucks(topSide: true),
                    ..._buildPucks(topSide: false),
                  ] else
                    Positioned.fill(child: gameLayer!),
                  const _HintArrows(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPucks({required bool topSide}) {
    final positions = topSide
        ? const [
            Offset(0.17, 0.18),
            Offset(0.33, 0.14),
            Offset(0.49, 0.22),
            Offset(0.63, 0.16),
            Offset(0.79, 0.21),
          ]
        : const [
            Offset(0.19, 0.79),
            Offset(0.35, 0.85),
            Offset(0.5, 0.76),
            Offset(0.66, 0.84),
            Offset(0.81, 0.78),
          ];

    return positions
        .map(
          (point) => Positioned.fill(
            child: Align(
              alignment: Alignment(point.dx * 2 - 1, point.dy * 2 - 1),
              child: _PuckChip(isPlayer: !topSide),
            ),
          ),
        )
        .toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Puck Chip
// ─────────────────────────────────────────────────────────────────────────────

class _PuckChip extends StatelessWidget {
  const _PuckChip({required this.isPlayer});

  final bool isPlayer;

  @override
  Widget build(BuildContext context) {
    // Player = icy white/cyan | Opponent = dark charcoal/red
    final accent =
        isPlayer ? const Color(0xFF1DE9FF) : const Color(0xFFFF4D6A);
    final baseColor =
        isPlayer ? const Color(0xFFD8F6FF) : const Color(0xFF1A1A22);

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: [
            Color.alphaBlend(Colors.white.withOpacity(0.35), baseColor),
            baseColor,
          ],
        ),
        border: Border.all(color: accent.withOpacity(0.70), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.45),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      // Specular highlight
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(isPlayer ? 0.55 : 0.18),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Hint Arrows
// ─────────────────────────────────────────────────────────────────────────────

class _HintArrows extends StatelessWidget {
  const _HintArrows();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _GlowArrow(icon: Icons.keyboard_arrow_down_rounded, flip: false),
            const SizedBox(height: 24),
            _GlowArrow(icon: Icons.keyboard_arrow_up_rounded, flip: true),
          ],
        ),
      ),
    );
  }
}

class _GlowArrow extends StatelessWidget {
  const _GlowArrow({required this.icon, required this.flip});

  final IconData icon;
  final bool flip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFC44D).withOpacity(0.10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC44D).withOpacity(0.30),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xCCFFC44D), size: 24),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Ice Board Painter
// ─────────────────────────────────────────────────────────────────────────────

class _IceBoardPainter extends CustomPainter {
  _IceBoardPainter({required this.highlightGap});

  final bool highlightGap;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(24));
    final rng = Random(42); // deterministic

    // ── Ice base ──────────────────────────────────────────────────────────
    final iceBase = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0B2540),
          Color(0xFF0A1E36),
          Color(0xFF061528),
        ],
      ).createShader(rect);
    canvas.drawRRect(rRect, iceBase);

    // ── Ice grain / surface texture ───────────────────────────────────────
    for (var i = 0; i < 26; i++) {
      final y = size.height * (i / 26);
      final wave = sin(i * 1.1) * 5.0;
      final opacity = 0.025 + rng.nextDouble() * 0.025;
      final grainPaint = Paint()
        ..color = const Color(0xFF1DE9FF).withOpacity(opacity)
        ..strokeWidth = 0.8;
      canvas.drawLine(
        Offset(0, y + wave),
        Offset(size.width, y - wave),
        grainPaint,
      );
    }

    // ── Rink centre circle ────────────────────────────────────────────────
    final centreX = size.width / 2;
    final centreY = size.height / 2;
    final circleR = size.width * 0.18;

    final centreFill = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1DE9FF).withOpacity(0.07),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(centreX, centreY), radius: circleR),
      );
    canvas.drawCircle(Offset(centreX, centreY), circleR, centreFill);

    final centreRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF1DE9FF).withOpacity(0.22);
    canvas.drawCircle(Offset(centreX, centreY), circleR, centreRing);

    // Centre dot
    canvas.drawCircle(
      Offset(centreX, centreY),
      3.5,
      Paint()..color = const Color(0xFF1DE9FF).withOpacity(0.55),
    );

    // ── Goal crease lines (top & bottom) ─────────────────────────────────
    final creaseWidth = size.width * 0.38;
    final creaseHeight = size.height * 0.08;
    final creasePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF1DE9FF).withOpacity(0.20);

    // Top crease
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(
          center: Offset(centreX, creaseHeight / 2 + 12),
          width: creaseWidth,
          height: creaseHeight,
        ),
        bottomLeft: const Radius.circular(8),
        bottomRight: const Radius.circular(8),
      ),
      creasePaint,
    );

    // Bottom crease
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(
          center: Offset(centreX, size.height - creaseHeight / 2 - 12),
          width: creaseWidth,
          height: creaseHeight,
        ),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      ),
      creasePaint,
    );

    // ── Divider wall ──────────────────────────────────────────────────────
    final dividerY = size.height * 0.5;
    final gapHalf = size.width * 0.10;
    final wallPaint = Paint()
      ..color = const Color(0xFF1A3D5C)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(18, dividerY),
      Offset(centreX - gapHalf, dividerY),
      wallPaint,
    );
    canvas.drawLine(
      Offset(centreX + gapHalf, dividerY),
      Offset(size.width - 18, dividerY),
      wallPaint,
    );

    // Divider edge highlight
    final wallHighlight = Paint()
      ..color = const Color(0xFF1DE9FF).withOpacity(0.22)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(18, dividerY),
      Offset(centreX - gapHalf, dividerY),
      wallHighlight,
    );
    canvas.drawLine(
      Offset(centreX + gapHalf, dividerY),
      Offset(size.width - 18, dividerY),
      wallHighlight,
    );

    // ── Gap glow ──────────────────────────────────────────────────────────
    if (highlightGap) {
      final gapGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFC44D).withOpacity(0.45),
            const Color(0xFFFFC44D).withOpacity(0.10),
            Colors.transparent,
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: Offset(centreX, dividerY),
            radius: 42,
          ),
        );
      canvas.drawCircle(Offset(centreX, dividerY), 42, gapGlow);

      // Gap centre dot
      canvas.drawCircle(
        Offset(centreX, dividerY),
        4,
        Paint()..color = const Color(0xCCFFC44D),
      );
    }

    // ── Inner vignette ────────────────────────────────────────────────────
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withOpacity(0.45)],
        stops: const [0.55, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rRect, vignette);

    // ── Board border ──────────────────────────────────────────────────────
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = const Color(0xFF1DE9FF).withOpacity(0.20);
    canvas.drawRRect(rRect, border);
  }

  @override
  bool shouldRepaint(covariant _IceBoardPainter oldDelegate) {
    return highlightGap != oldDelegate.highlightGap;
  }
}