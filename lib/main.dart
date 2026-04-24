import 'package:flutter/material.dart';

import 'controllers/game_flow_controller.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SlingPuckApp());
}

class SlingPuckApp extends StatelessWidget {
  const SlingPuckApp({super.key});

  @override
  Widget build(BuildContext context) {
    final flowController = GameFlowController();

    return MaterialApp(
      title: 'Sling Puck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF071317),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF31D0AA),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: SplashScreen(flowController: flowController),
    );
  }
}
