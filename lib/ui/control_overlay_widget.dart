import 'package:flutter/material.dart';

class ControlOverlayWidget extends StatelessWidget {
  const ControlOverlayWidget({
    super.key,
    this.onUndo,
    this.onBoost,
    this.isAiming = true,
  });

  final VoidCallback? onUndo;
  final VoidCallback? onBoost;
  final bool isAiming;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: [
          // Ambient gradient veil
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF070B14).withOpacity(0.38),
                  ],
                ),
              ),
            ),
          ),

          // Center puck + aim guide
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                _SelectedPuck(isAiming: isAiming),
                const SizedBox(height: 6),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: isAiming ? 1 : 0,
                  child: const _AimGuide(),
                ),
              ],
            ),
          ),

          // Undo — bottom left
          Positioned(
            left: 14,
            bottom: 14,
            child: _ActionCircleButton(
              icon: Icons.undo_rounded,
              accent: const Color(0xFF1DE9FF),
              onTap: onUndo,
            ),
          ),

          // Boost — bottom right
          Positioned(
            right: 14,
            bottom: 14,
            child: _ActionCircleButton(
              icon: Icons.bolt_rounded,
              accent: const Color(0xFFFFC44D),
              onTap: onBoost,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Selected Puck
// ─────────────────────────────────────────────────────────────────────────────

class _SelectedPuck extends StatelessWidget {
  const _SelectedPuck({required this.isAiming});

  final bool isAiming;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      scale: isAiming ? 1.1 : 1.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isAiming ? 52 : 44,
            height: isAiming ? 52 : 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF1DE9FF).withOpacity(isAiming ? 0.35 : 0.0),
                width: 1.5,
              ),
            ),
          ),
          // Puck body
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFE8F4FF), Color(0xFFB8D4EC)],
                center: Alignment(-0.3, -0.3),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.75),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1DE9FF).withOpacity(isAiming ? 0.55 : 0.25),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.18),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            // Puck shine detail
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.45),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Aim Guide
// ─────────────────────────────────────────────────────────────────────────────

class _AimGuide extends StatelessWidget {
  const _AimGuide();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 2,
          height: 16,
          child: CustomPaint(
            painter: _DottedLinePainter(),
          ),
        ),
        const SizedBox(height: 0),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1DE9FF).withOpacity(0.12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1DE9FF).withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_upward_rounded,
            color: Color(0xCC1DE9FF),
            size: 18,
          ),
        ),
      ],
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dotCount = 8;
    const dot = 3.5;
    const gap = 5.5;
    final totalSpan = dotCount * dot + (dotCount - 1) * gap;
    double y = (size.height - totalSpan) / 2 + totalSpan;

    for (int i = 0; i < dotCount; i++) {
      final opacity = 0.25 + 0.75 * (i / (dotCount - 1));
      final paint = Paint()
        ..color = const Color(0xFF1DE9FF).withOpacity(opacity)
        ..strokeWidth = size.width
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y - dot),
        paint,
      );
      y -= dot + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Action Circle Button
// ─────────────────────────────────────────────────────────────────────────────

class _ActionCircleButton extends StatefulWidget {
  const _ActionCircleButton({
    required this.icon,
    required this.accent,
    this.onTap,
  });

  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  @override
  State<_ActionCircleButton> createState() => _ActionCircleButtonState();
}

class _ActionCircleButtonState extends State<_ActionCircleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.87).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _ctrl.forward();
    await _ctrl.reverse();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.accent.withOpacity(0.18),
                const Color(0xFF070B14).withOpacity(0.90),
              ],
            ),
            border: Border.all(
              color: widget.accent.withOpacity(0.48),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withOpacity(0.32),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Colors.black54,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(widget.icon, color: widget.accent, size: 26),
        ),
      ),
    );
  }
}