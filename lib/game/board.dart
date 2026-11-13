import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../data/catalog.dart';

/// Playing surface: frame, planks, side zones, elastic bands and the gap posts.
class Board extends PositionComponent {
  Board({required Vector2 boardSize, required this.skin, required this.band, required this.gapWidth, this.soloTop = false})
    : super(size: boardSize, anchor: Anchor.topLeft, priority: 0);

  final BoardSkin skin;
  final BandSkin band;
  final double gapWidth;
  final bool soloTop;

  static const frameWidth = 16.0;

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(-frameWidth, -frameWidth, w + frameWidth * 2, h + frameWidth * 2),
      const Radius.circular(28),
    );
    final inner = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(14));

    // Frame with bevel highlight.
    canvas.drawRRect(
      outer.shift(const Offset(0, 8)),
      Paint()
        ..color = const Color(0x80000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skin.frameLight, skin.frame, skin.frame],
        ).createShader(outer.outerRect),
    );
    canvas.drawRRect(
      outer.deflate(5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFE2B04A).withValues(alpha: 0.9),
    );

    // Surface
    canvas.save();
    canvas.clipRRect(inner);
    if (skin.ice) {
      canvas.drawRect(
        inner.outerRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [skin.plankA, skin.plankB, skin.plankA],
          ).createShader(inner.outerRect),
      );
      final scratch = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = 1.2;
      for (var i = 0; i < 9; i++) {
        final y = 60.0 + i * 78;
        canvas.drawLine(Offset(20 + (i * 37) % 120, y), Offset(140 + (i * 53) % 220, y + 30), scratch);
      }
    } else {
      const plank = 34.0;
      for (var x = 0.0, i = 0; x < w; x += plank, i++) {
        canvas.drawRect(Rect.fromLTWH(x, 0, plank, h), Paint()..color = i.isEven ? skin.plankA : skin.plankB);
        canvas.drawRect(Rect.fromLTWH(x + plank - 2, 0, 2, h), Paint()..color = Colors.black.withValues(alpha: 0.08));
      }
      // Grain sheen
      canvas.drawRect(
        inner.outerRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withValues(alpha: 0.12), Colors.transparent, Colors.black.withValues(alpha: 0.12)],
          ).createShader(inner.outerRect),
      );
    }

    // Side tints: top = opponent (tide), bottom = player (ember).
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h / 2), Paint()..color = const Color(0xFF3DD6F5).withValues(alpha: soloTop ? 0.10 : 0.06));
    canvas.drawRect(Rect.fromLTWH(0, h / 2, w, h / 2), Paint()..color = const Color(0xFFFF8A3D).withValues(alpha: 0.07));

    // Inner vignette
    canvas.drawRRect(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.restore();

    _band(canvas, 46, w);
    _band(canvas, h - 46, w);

    // Brass posts at the gap edges.
    final gl = (w - gapWidth) / 2;
    final gr = gl + gapWidth;
    _post(canvas, Offset(gl, h / 2));
    _post(canvas, Offset(gr, h / 2));
  }

  void _band(Canvas canvas, double y, double w) {
    final p1 = Offset(14, y);
    final p2 = Offset(w - 14, y);
    if (band.glow) {
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = band.color.withValues(alpha: 0.6)
          ..strokeWidth = 9
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    canvas.drawLine(
      p1.translate(0, 2),
      p2.translate(0, 2),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..strokeWidth = 4,
    );
    canvas.drawLine(
      p1,
      p2,
      Paint()
        ..color = band.color
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    _peg(canvas, p1);
    _peg(canvas, p2);
  }

  void _peg(Canvas canvas, Offset c) {
    canvas.drawCircle(c.translate(0, 2), 8, Paint()..color = Colors.black.withValues(alpha: 0.35));
    canvas.drawCircle(
      c,
      8,
      Paint()
        ..shader = ui.Gradient.radial(
          c.translate(-2, -3),
          9,
          const [Color(0xFFFFE6A6), Color(0xFFE2B04A), Color(0xFF9A6E1C)],
          const [0, 0.5, 1],
        ),
    );
  }

  void _post(Canvas canvas, Offset c) {
    final r = Rect.fromCenter(center: c, width: 8, height: 26);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r.shift(const Offset(0, 3)), const Radius.circular(4)),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(4)),
      Paint()..shader = const LinearGradient(colors: [Color(0xFFFFE6A6), Color(0xFFE2B04A), Color(0xFF9A6E1C)]).createShader(r),
    );
  }
}
