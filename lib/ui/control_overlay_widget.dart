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
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.22),
                  ],
                ),
              ),
            ),
          ),
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
          Positioned(
            left: 14,
            bottom: 14,
            child: _ActionCircleButton(
              icon: Icons.undo_rounded,
              onTap: onUndo,
            ),
          ),
          Positioned(
            right: 14,
            bottom: 14,
            child: _ActionCircleButton(
              icon: Icons.bolt_rounded,
              background: const Color(0xFF3B2718),
              iconColor: const Color(0xFFFFB93E),
              glow: const Color(0xAAFF8E31),
              onTap: onBoost,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedPuck extends StatelessWidget {
  const _SelectedPuck({required this.isAiming});

  final bool isAiming;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      scale: isAiming ? 1.08 : 1,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF3F3F3),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xAAFFFFFF),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _AimGuide extends StatelessWidget {
  const _AimGuide();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 2,
          height: 58,
          child: CustomPaint(
            painter: _DottedLinePainter(),
          ),
        ),
        const Icon(
          Icons.arrow_upward_rounded,
          color: Color(0xB3FFFFFF),
          size: 20,
        ),
      ],
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xCCFFFFFF)
      ..strokeWidth = size.width
      ..strokeCap = StrokeCap.round;

    const dot = 4.0;
    const gap = 5.0;
    double y = size.height;
    while (y > 0) {
      canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, y - dot), paint);
      y -= dot + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ActionCircleButton extends StatefulWidget {
  const _ActionCircleButton({
    required this.icon,
    this.background = const Color(0x2EFFFFFF),
    this.iconColor = Colors.white,
    this.glow = const Color(0x5531D0AA),
    this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final Color glow;
  final VoidCallback? onTap;

  @override
  State<_ActionCircleButton> createState() => _ActionCircleButtonState();
}

class _ActionCircleButtonState extends State<_ActionCircleButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.9),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 130),
        scale: _scale,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.background,
            border: Border.all(color: Colors.white.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(color: widget.glow, blurRadius: 18, spreadRadius: 2),
              const BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 5)),
            ],
          ),
          child: Icon(widget.icon, color: widget.iconColor, size: 28),
        ),
      ),
    );
  }
}
