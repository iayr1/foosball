import 'package:flutter/material.dart';

import 'ui/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SlingPuckApp());
}

class SlingPuckApp extends StatelessWidget {
  const SlingPuckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sling Puck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B5A2B)),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
