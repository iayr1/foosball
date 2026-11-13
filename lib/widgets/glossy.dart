import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/catalog.dart';
import '../data/profile.dart';
import '../theme/arena_theme.dart';

void tapFeedback() {
  if (Profile.instance.haptics) HapticFeedback.lightImpact();
}

/// Layout helpers shared by every screen.
extension ResponsiveX on BuildContext {
  Size get screen => MediaQuery.sizeOf(this);
  bool get isLandscape => screen.width > screen.height;
}

/// Horizontal padding that keeps content at most [maxContent] wide and centred,
/// while scroll views still span the full width (so edges stay scrollable).
EdgeInsets centeredPadding(double width, {double maxContent = 640, double min = 20, double top = 0, double bottom = 0}) {
  final side = math.max(min, (width - maxContent) / 2);
  return EdgeInsets.fromLTRB(side, top, side, bottom);
}

/// Centres [child] and limits its width.
class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, required this.child, this.maxWidth = 640});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

/// A modal card (pause, chest, settings) that fits any screen: limited width,
/// and scrolls instead of overflowing when the screen is short.
class FitCard extends StatelessWidget {
  const FitCard({super.key, required this.child, this.maxWidth = 360});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: Arena.metalGradient,
              boxShadow: const [BoxShadow(color: Color(0xFF2A3142), offset: Offset(0, 6))],
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: Arena.panelGradient),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Scales down while pressed, gives haptic feedback, and exposes a button to accessibility.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.semanticLabel, this.enabled = true});

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool enabled;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  bool get _active => widget.enabled && widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _active,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _active ? (_) => setState(() => _down = true) : null,
        onTapCancel: _active ? () => setState(() => _down = false) : null,
        onTapUp: _active ? (_) => setState(() => _down = false) : null,
        onTap: _active
            ? () {
                tapFeedback();
                widget.onTap!();
              }
            : null,
        child: AnimatedScale(
          scale: _down ? 0.94 : 1,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Chunky two-tone glossy button with a metal rim and a 3D drop edge.
class GlossyButton extends StatelessWidget {
  const GlossyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gloss = Gloss.orange,
    this.height = 64,
    this.fontSize = 28,
    this.icon,
    this.enabled = true,
    this.radius,
  });

  final String label;
  final VoidCallback? onTap;
  final Gloss gloss;
  final double height;
  final double fontSize;
  final IconData? icon;
  final bool enabled;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final g = enabled ? gloss : Gloss.locked;
    final r = radius ?? height * 0.36;
    final textColor = enabled ? Colors.white : Arena.dim;
    return Pressable(
      onTap: onTap,
      enabled: enabled,
      semanticLabel: label,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          border: Border.all(color: enabled ? Arena.rim : Arena.panelEdge, width: height > 50 ? 4 : 3),
          gradient: g.gradient,
          boxShadow: [
            BoxShadow(color: enabled ? Arena.dropEdge : const Color(0xFF0A101C), offset: const Offset(0, 5)),
            if (enabled) const BoxShadow(color: Color(0x73000000), blurRadius: 18, offset: Offset(0, 12)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r - 3),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 10,
                right: 10,
                top: 2,
                height: height * 0.36,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(r),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: enabled ? 0.55 : 0.08),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: textColor, size: fontSize * 1.05, shadows: enabled ? Arena.outlineShadows(g.outline, 2) : null),
                      SizedBox(width: fontSize * 0.3),
                    ],
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: Arena.display(fontSize, color: textColor, outline: enabled ? g.outline : null),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round glossy icon button with a silver rim.
class RoundGlossButton extends StatelessWidget {
  const RoundGlossButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.gloss = Gloss.gold,
    this.size = 48,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String semanticLabel;
  final Gloss gloss;
  final double size;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: SizedBox(
        width: size,
        height: size + 4,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Arena.rim, width: size > 56 ? 4 : 3),
                gradient: gloss.gradient,
                boxShadow: const [BoxShadow(color: Arena.dropEdge, offset: Offset(0, 4))],
              ),
              child: ClipOval(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: size * 0.14,
                      right: size * 0.14,
                      top: 1,
                      height: size * 0.38,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(size),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white.withValues(alpha: 0.6), Colors.white.withValues(alpha: 0)],
                          ),
                        ),
                      ),
                    ),
                    Icon(icon, color: Colors.white, size: size * 0.48, shadows: Arena.outlineShadows(gloss.outline, 2)),
                  ],
                ),
              ),
            ),
            if (badge)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF24B4B),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Beveled navy panel used for cards.
class BevelPanel extends StatelessWidget {
  const BevelPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 20,
    this.borderColor = Arena.panelEdge,
    this.gradient = Arena.panelGradient,
    this.borderWidth = 2,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color borderColor;
  final Gradient gradient;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: gradient,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: const [BoxShadow(color: Color(0xFF0A101C), offset: Offset(0, 4))],
      ),
      child: child,
    );
  }
}

/// Metal-framed progress bar.
class MetalBar extends StatelessWidget {
  const MetalBar({super.key, required this.value, this.gloss = Gloss.gold, this.label, this.height = 26});

  final double value;
  final Gloss gloss;
  final String? label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        gradient: Arena.metalGradient,
        boxShadow: const [BoxShadow(color: Color(0xFF2A3142), offset: Offset(0, 3))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Stack(
          children: [
            Container(color: Arena.night),
            FractionallySizedBox(
              widthFactor: v,
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(height / 2), gradient: gloss.gradient),
              ),
            ),
            if (label != null)
              Center(
                child: Text(label!, style: Arena.display(height * 0.5, outline: Arena.deepNight, letterSpacing: 0.5)),
              ),
          ],
        ),
      ),
    );
  }
}

class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.2, -0.3),
            colors: [Color(0xFFFFF1B8), Color(0xFFFFC23A), Color(0xFFD98A06)],
            stops: [0, 0.5, 1],
          ),
          border: Border.all(color: const Color(0xFFF2A21E), width: size * 0.09),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 2))],
        ),
        alignment: Alignment.center,
        child: Text(
          '\$',
          style: Arena.display(size * 0.5, color: Colors.white, outline: const Color(0xFF8A5004), letterSpacing: 0),
        ),
      ),
    );
  }
}

class GemIcon extends StatelessWidget {
  const GemIcon({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: size * 0.68,
              height: size * 0.68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE6FBFF), Color(0xFF6FE3FA), Color(0xFF1A9CC4)],
                  stops: [0, 0.4, 1],
                ),
                boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 2))],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StarIcon extends StatelessWidget {
  const StarIcon({super.key, this.size = 40, this.filled = true});
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _StarPainter(filled));
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.filled);
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final c = size.center(Offset.zero);
    final outer = size.width / 2;
    final inner = outer * 0.48;
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    final fill = Paint()
      ..shader =
          (filled
                  ? const LinearGradient(
                      colors: [Color(0xFFFFE08A), Color(0xFFFFB547), Color(0xFFE8961A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : const LinearGradient(colors: [Color(0xFF2A3550), Color(0xFF1D2945)]))
              .createShader(Offset.zero & size);
    canvas.drawPath(path, fill);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.05
        ..strokeJoin = StrokeJoin.round
        ..color = filled ? const Color(0xFF8A4A0C) : const Color(0xFF141C2E),
    );
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.filled != filled;
}

/// Glossy 3D puck used in menus and the store.
class PuckOrb extends StatelessWidget {
  const PuckOrb({super.key, required this.skin, this.size = 48});
  final PuckSkin skin;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: PuckPainter(skin));
}

class PuckPainter extends CustomPainter {
  PuckPainter(this.skin, {this.shadow = true});
  final PuckSkin skin;
  final bool shadow;

  static void paintPuck(Canvas canvas, Offset center, double r, PuckSkin skin, {bool shadow = true}) {
    if (shadow) {
      canvas.drawCircle(
        center + Offset(0, r * 0.22),
        r,
        Paint()
          ..color = const Color(0x59000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
    final rect = Rect.fromCircle(center: center, radius: r);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.25, -0.4),
          radius: 0.95,
          colors: [skin.light, skin.base, skin.dark],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );
    // Rim ring
    canvas.drawCircle(
      center,
      r * 0.72,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.08
        ..color = skin.dark.withValues(alpha: 0.35),
    );
    // Specular highlight
    final hl = Rect.fromCenter(center: center + Offset(-r * 0.18, -r * 0.42), width: r * 1.0, height: r * 0.55);
    canvas.drawOval(
      hl,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.85), Colors.white.withValues(alpha: 0)],
        ).createShader(hl),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    paintPuck(canvas, size.center(Offset.zero), size.width / 2 * 0.9, skin, shadow: shadow);
  }

  @override
  bool shouldRepaint(PuckPainter old) => old.skin != skin;
}

/// Simple drawn chest. [glow] pulses when ready to open.
class ChestIcon extends StatelessWidget {
  const ChestIcon({
    super.key,
    this.size = 56,
    this.body = const Color(0xFF9A5524),
    this.lid = const Color(0xFFC26A2C),
    this.trim = const Color(0xFF5A3218),
  });

  final double size;
  final Color body;
  final Color lid;
  final Color trim;

  static const wood = ChestIcon();

  @override
  Widget build(BuildContext context) {
    final w = size;
    final h = size * 0.84;
    return ExcludeSemantics(
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: body,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(w * 0.22), bottom: Radius.circular(w * 0.12)),
                  border: Border.all(color: trim, width: w * 0.05),
                  boxShadow: const [BoxShadow(color: Color(0x73000000), blurRadius: 8, offset: Offset(0, 4))],
                ),
              ),
            ),
            Positioned(
              left: w * 0.05,
              right: w * 0.05,
              top: w * 0.05,
              height: h * 0.34,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: lid,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(w * 0.18)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: h * 0.38,
              height: w * 0.06,
              child: ColoredBox(color: trim),
            ),
            Positioned(
              left: w * 0.38,
              width: w * 0.24,
              top: h * 0.28,
              height: h * 0.32,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD36B),
                  borderRadius: BorderRadius.circular(w * 0.05),
                  border: Border.all(color: const Color(0xFF8A5004), width: w * 0.035),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Coin/gem balance pill for top bars.
class CurrencyPill extends StatelessWidget {
  const CurrencyPill({super.key, required this.icon, required this.value, this.onTap, required this.semanticLabel});

  final Widget icon;
  final int value;
  final VoidCallback? onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      height: 34,
      padding: const EdgeInsets.only(left: 4, right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        gradient: Arena.panelGradient,
        border: Border.all(color: Arena.panelEdge, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Text(
              formatNumber(value),
              key: ValueKey(value),
              style: Arena.body(14, weight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
    return Pressable(onTap: onTap, semanticLabel: semanticLabel, child: pill);
  }
}

String formatNumber(int n) {
  final s = n.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return n < 0 ? '-$b' : b.toString();
}

/// Page background with soft warm glow; content is placed in a SafeArea.
class ArenaScaffold extends StatelessWidget {
  const ArenaScaffold({super.key, required this.child, this.glow = Arena.ember});

  final Widget child;
  final Color glow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: Arena.pageGradient),
        child: Stack(
          children: [
            Positioned(
              left: -140,
              right: -140,
              top: 90,
              height: 460,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: RadialGradient(colors: [glow.withValues(alpha: 0.2), glow.withValues(alpha: 0)])),
                ),
              ),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}

/// Back button + title header used by inner pages.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          RoundGlossButton(icon: Icons.arrow_back_rounded, semanticLabel: 'Back', onTap: () => Navigator.of(context).maybePop()),
          const SizedBox(width: 14),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(title, style: Arena.display(30), maxLines: 1),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerRight, child: trailing!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Animated toggle switch in the glossy style.
class GlossSwitch extends StatelessWidget {
  const GlossSwitch({super.key, required this.value, required this.onChanged, required this.label});

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: label,
      child: Pressable(
        onTap: () => onChanged(!value),
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              Expanded(child: Text(label, style: Arena.body(16))),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 56,
                height: 32,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: value ? Gloss.orange.gradient : null,
                  color: value ? null : Arena.track,
                  border: Border.all(color: value ? Arena.rim : Arena.panelEdge, width: 2),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Arena.chalk,
                      boxShadow: [BoxShadow(color: Color(0x55000000), blurRadius: 3, offset: Offset(0, 1))],
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
