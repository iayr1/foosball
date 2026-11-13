import 'package:flutter/material.dart';

/// Colour, gradient and type tokens for the Sling Arena look.
class Arena {
  Arena._();

  // Grounds
  static const night = Color(0xFF0E1626);
  static const deepNight = Color(0xFF0B111E);
  static const panel = Color(0xFF17223A);
  static const panelTop = Color(0xFF24355E);
  static const panelEdge = Color(0xFF3B4D74);
  static const track = Color(0xFF263552);
  static const inset = Color(0xFF121C30);

  // Text
  static const chalk = Color(0xFFF3F1EA);
  static const muted = Color(0xFF9AA6BF);
  static const dim = Color(0xFF6B7894);

  // Accents
  static const ember = Color(0xFFFF8A3D);
  static const tide = Color(0xFF3DD6F5);
  static const gold = Color(0xFFFFB547);
  static const brass = Color(0xFFE2B04A);
  static const rose = Color(0xFFFF8FA6);

  // Metal rim used by glossy controls
  static const rim = Color(0xFFDCE2EC);
  static const dropEdge = Color(0xFF4A5468);

  static const panelGradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [panelTop, panel]);

  static const metalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF4F7FB), Color(0xFF8C96A8), Color(0xFF5B6577)],
    stops: [0, 0.6, 1],
  );

  static const pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF131E35), night, deepNight],
    stops: [0, 0.45, 1],
  );

  // Text styles
  static TextStyle display(double size, {Color color = chalk, Color? outline, double letterSpacing = 1.5}) {
    return TextStyle(
      fontFamily: 'LilitaOne',
      fontSize: size,
      height: 1.05,
      color: color,
      letterSpacing: letterSpacing,
      shadows: outline == null ? null : outlineShadows(outline, size >= 28 ? 3 : 2),
    );
  }

  static TextStyle body(double size, {FontWeight weight = FontWeight.w800, Color color = chalk, double letterSpacing = 0}) {
    return TextStyle(
      fontFamily: 'Nunito',
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation('wght', weight.value.toDouble())],
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle label(double size, {Color color = muted}) => body(size, weight: FontWeight.w900, color: color, letterSpacing: 2);

  static List<Shadow> outlineShadows(Color c, double depth) => [
    Shadow(color: c, offset: Offset(0, depth)),
    Shadow(color: c, offset: const Offset(1.6, 0)),
    Shadow(color: c, offset: const Offset(-1.6, 0)),
    Shadow(color: c, offset: const Offset(0, -1.6)),
  ];

  static ThemeData theme() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: night,
      fontFamily: 'Nunito',
      colorScheme: const ColorScheme.dark(primary: ember, secondary: tide, surface: panel),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: _FadeScaleTransitionsBuilder(), TargetPlatform.iOS: _FadeScaleTransitionsBuilder()},
      ),
    );
  }
}

/// A gloss "skin" for buttons: four stops give the two-tone shine.
class Gloss {
  final List<Color> stops;
  final Color outline;
  const Gloss(this.stops, this.outline);

  LinearGradient get gradient =>
      LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: stops, stops: const [0, 0.48, 0.52, 1]);

  static const orange = Gloss([Color(0xFFFFC46E), Color(0xFFFF9A45), Color(0xFFF07A28), Color(0xFFD35E14)], Color(0xFF7A3206));
  static const green = Gloss([Color(0xFF9CF27A), Color(0xFF5ED43E), Color(0xFF43B829), Color(0xFF2E9A1E)], Color(0xFF1D5A10));
  static const blue = Gloss([Color(0xFF8BEBFF), Color(0xFF4FD2F2), Color(0xFF2BB8DD), Color(0xFF1A8FB0)], Color(0xFF0B4A60));
  static const red = Gloss([Color(0xFFFF8A8A), Color(0xFFF24B4B), Color(0xFFDB3030), Color(0xFFA81C1C)], Color(0xFF5E0C0C));
  static const gold = Gloss([Color(0xFFFFD36B), Color(0xFFF7B12A), Color(0xFFE8961A), Color(0xFFC97A0C)], Color(0xFF7A4A06));
  static const purple = Gloss([Color(0xFFC9A8FF), Color(0xFF9467F0), Color(0xFF7A4BDB), Color(0xFF5530A8)], Color(0xFF2E1468));
  static const locked = Gloss([Color(0xFF2C3B5C), Color(0xFF263552), Color(0xFF223050), Color(0xFF1D2945)], Color(0xFF0E1626));
}

class _FadeScaleTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeScaleTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(curved), child: child),
    );
  }
}
