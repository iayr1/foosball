import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../ui/game_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.mode});

  final GameMode mode;

  @override
  Widget build(BuildContext context) {
    return SlingPuckGameView(mode: mode);
  }
}
