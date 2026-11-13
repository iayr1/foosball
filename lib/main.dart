import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'audio/sfx_service.dart';
import 'data/profile.dart';
import 'game/physics.dart';
import 'screens/splash_screen.dart';
import 'theme/arena_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  final profile = Profile.instance;
  await profile.load();
  await SfxService.instance.initialize();
  SfxService.instance.setEnabled(profile.sound);
  PhysicsEngine.hapticsEnabled = profile.haptics;

  runApp(const SlingArenaApp());
}

class SlingArenaApp extends StatelessWidget {
  const SlingArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sling Arena',
      debugShowCheckedModeBanner: false,
      theme: Arena.theme(),
      // Respect the system font size, but cap it so chunky game UI keeps its shape.
      builder: (context, child) => MediaQuery.withClampedTextScaling(maxScaleFactor: 1.2, child: child!),
      home: const SplashScreen(),
    );
  }
}
