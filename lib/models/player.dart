import 'package:flutter/material.dart';

/// Lightweight model that describes each player in the match.
class Player {
  final String id;
  final String name;
  final Color puckColor;
  final bool startsOnTop;

  const Player({
    required this.id,
    required this.name,
    required this.puckColor,
    required this.startsOnTop,
  });
}
