import 'package:flutter/material.dart';

/// Reusable premium button with press-scale animation.
class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.gradient,
    this.backgroundColor,
    this.onTap,
    this.height = 78,
    this.radius = 18,
    this.expanded = true,
    this.textColor = Colors.white,
  });

  final String title;
  final String? subtitle;
  final Widget? icon;
  final Gradient? gradient;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double height;
  final double radius;
  final bool expanded;
  final Color textColor;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _scale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? const Color(0xFF1A1A1A),
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: Colors.white.withOpacity(0.14), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: (widget.gradient == null
                      ? widget.backgroundColor ?? const Color(0xFF333333)
                      : Colors.white)
                  .withOpacity(0.08),
              blurRadius: 14,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        color: widget.textColor.withOpacity(0.86),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final tappable = GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapCancel: () => setState(() => _scale = 1),
      onTapUp: (_) => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: content,
    );

    if (widget.expanded) return tappable;
    return IntrinsicWidth(child: tappable);
  }
}
