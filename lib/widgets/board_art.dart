import 'package:flutter/material.dart';

import '../data/catalog.dart';
import 'glossy.dart';

/// Small drawn board for menus and store previews.
class MiniBoard extends StatelessWidget {
  const MiniBoard({super.key, required this.board, required this.band, this.topPuck, this.bottomPuck, this.width = 220, this.height = 290});

  final BoardSkin board;
  final BandSkin band;
  final PuckSkin? topPuck;
  final PuckSkin? bottomPuck;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(size: Size(width, height), painter: _MiniBoardPainter(board, band, topPuck, bottomPuck)),
    );
  }
}

class _MiniBoardPainter extends CustomPainter {
  _MiniBoardPainter(this.board, this.band, this.top, this.bottom);

  final BoardSkin board;
  final BandSkin band;
  final PuckSkin? top;
  final PuckSkin? bottom;

  @override
  void paint(Canvas canvas, Size s) {
    final f = s.width * 0.055;
    final outer = RRect.fromRectAndRadius(Offset.zero & s, Radius.circular(s.width * 0.1));
    canvas.drawRRect(
      outer.shift(const Offset(0, 10)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [board.frameLight, board.frame],
        ).createShader(Offset.zero & s),
    );
    canvas.drawRRect(
      outer.deflate(f * 0.35),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFE2B04A),
    );

    final innerRect = Rect.fromLTWH(f, f, s.width - f * 2, s.height - f * 2);
    final inner = RRect.fromRectAndRadius(innerRect, Radius.circular(s.width * 0.05));
    canvas.save();
    canvas.clipRRect(inner);
    if (board.ice) {
      canvas.drawRect(
        innerRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [board.plankA, board.plankB],
          ).createShader(innerRect),
      );
    } else {
      final plank = innerRect.width / 7;
      for (var i = 0; i < 7; i++) {
        canvas.drawRect(
          Rect.fromLTWH(innerRect.left + i * plank, innerRect.top, plank, innerRect.height),
          Paint()..color = i.isEven ? board.plankA : board.plankB,
        );
      }
    }
    canvas.restore();

    final midY = s.height / 2;
    final wallH = s.height * 0.028;
    final gapW = innerRect.width * 0.24;
    final sideW = (innerRect.width - gapW) / 2;
    final wallPaint = Paint()..color = board.frame;
    canvas.drawRect(Rect.fromLTWH(innerRect.left, midY - wallH / 2, sideW, wallH), wallPaint);
    canvas.drawRect(Rect.fromLTWH(innerRect.right - sideW, midY - wallH / 2, sideW, wallH), wallPaint);
    final post = Paint()..color = const Color(0xFFE2B04A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(innerRect.left + sideW, midY), width: 3, height: wallH * 2),
        const Radius.circular(2),
      ),
      post,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(innerRect.right - sideW, midY), width: 3, height: wallH * 2),
        const Radius.circular(2),
      ),
      post,
    );

    final bandPaint = Paint()
      ..color = band.color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final by1 = innerRect.top + innerRect.height * 0.07;
    final by2 = innerRect.bottom - innerRect.height * 0.07;
    canvas.drawLine(Offset(innerRect.left + 6, by1), Offset(innerRect.right - 6, by1), bandPaint);
    canvas.drawLine(Offset(innerRect.left + 6, by2), Offset(innerRect.right - 6, by2), bandPaint);

    final r = s.width * 0.058;
    if (top != null) {
      for (final p in const [Offset(0.22, 0.16), Offset(0.55, 0.24), Offset(0.4, 0.36)]) {
        PuckPainter.paintPuck(canvas, Offset(innerRect.left + innerRect.width * p.dx, innerRect.top + innerRect.height * p.dy), r, top!);
      }
    }
    if (bottom != null) {
      for (final p in const [Offset(0.3, 0.8), Offset(0.7, 0.72), Offset(0.6, 0.6)]) {
        PuckPainter.paintPuck(canvas, Offset(innerRect.left + innerRect.width * p.dx, innerRect.top + innerRect.height * p.dy), r, bottom!);
      }
    }
  }

  @override
  bool shouldRepaint(_MiniBoardPainter old) => old.board != board || old.band != band || old.top != top || old.bottom != bottom;
}
