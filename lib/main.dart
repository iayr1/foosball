import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/game_over_screen.dart';
import 'screens/game_screen.dart';
import 'screens/menu_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Winner Foosball',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF31D0AA)),
        scaffoldBackgroundColor: const Color(0xFF0B1118),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MenuScreen(),
        '/game': (context) => const GameScreen(),
        '/gameover': (context) => const GameOverScreen(),
      },
    );
  }
}
