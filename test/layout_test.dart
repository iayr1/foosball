// Renders every screen and dialog at common phone/tablet sizes, in portrait
// and landscape, and fails on any layout overflow or exception.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foosball/data/match_config.dart';
import 'package:foosball/data/profile.dart';
import 'package:foosball/screens/academy_screen.dart';
import 'package:foosball/screens/home_screen.dart';
import 'package:foosball/screens/match_screen.dart';
import 'package:foosball/screens/modes_screen.dart';
import 'package:foosball/screens/profile_screen.dart';
import 'package:foosball/screens/result_screen.dart';
import 'package:foosball/screens/settings_sheet.dart';
import 'package:foosball/screens/splash_screen.dart';
import 'package:foosball/screens/store_screen.dart';
import 'package:foosball/theme/arena_theme.dart';
import 'package:foosball/widgets/chest_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

const sizes = <String, Size>{
  'small phone': Size(320, 568),
  'phone': Size(360, 780),
  'tall phone': Size(412, 915),
  'small landscape': Size(568, 320),
  'phone landscape': Size(780, 360),
  'tablet': Size(800, 1280),
  'tablet landscape': Size(1280, 800),
};

Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

RewardSummary _summary() => RewardSummary(
  coins: 140,
  gems: 5,
  xp: 45,
  stars: 3,
  leveledUp: true,
  newLevel: 4,
  chestEarned: true,
  unlocked: Profile.allAchievements.take(2).toList(),
  tournamentWon: false,
);

Future<void> _pumpAt(WidgetTester tester, Size size, Widget home, {double textScale = 1}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: Arena.theme(),
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)), child: child!),
      home: home,
    ),
  );
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 6));
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await _loadFont('LilitaOne', 'assets/fonts/LilitaOne-Regular.ttf');
    await _loadFont('Nunito', 'assets/fonts/Nunito.ttf');
    final p = Profile.instance;
    p.coins = 123456;
    p.gems = 9999;
    p.chestsReady = 1;
    p.chestProgress = 3;
  });

  final screens = <String, Widget Function()>{
    'splash': () => const SplashScreen(),
    'home': () => const HomeScreen(),
    'modes': () => const ModesScreen(),
    'store': () => const StoreScreen(),
    'profile': () => const ProfileScreen(),
    'academy': () => const AcademyScreen(),
    'result win': () => ResultScreen(
      config: const MatchConfig(style: PlayStyle.tournament, difficulty: Difficulty.legend, tournamentRound: 2),
      playerWon: true,
      summary: _summary(),
      seconds: 75,
      playerSent: 5,
      opponentSent: 3,
    ),
    'match vs ai': () => const MatchScreen(
      config: MatchConfig(style: PlayStyle.vsAi, difficulty: Difficulty.legend, pucksPerSide: 7),
    ),
    'match timed': () => MatchScreen(config: MatchConfig.timeAttack(5)),
  };

  for (final size in sizes.entries) {
    for (final screen in screens.entries) {
      testWidgets('${screen.key} @ ${size.key}', (tester) async {
        await _pumpAt(tester, size.value, screen.value());
        expect(tester.takeException(), isNull);
        await _dispose(tester);
      });
    }

    testWidgets('settings sheet @ ${size.key}', (tester) async {
      await _pumpAt(
        tester,
        size.value,
        Scaffold(
          body: Builder(
            builder: (c) => Center(
              child: TextButton(onPressed: () => showSettingsSheet(c), child: const Text('open')),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
      await _dispose(tester);
    });

    testWidgets('chest dialog @ ${size.key}', (tester) async {
      Profile.instance.chestsReady = 1;
      await _pumpAt(
        tester,
        size.value,
        Scaffold(
          body: Builder(
            builder: (c) => Center(
              child: TextButton(onPressed: () => showChestDialog(c), child: const Text('open')),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
      await _dispose(tester);
    });

    testWidgets('pause menu @ ${size.key}', (tester) async {
      await _pumpAt(tester, size.value, const MatchScreen(config: MatchConfig(style: PlayStyle.vsAi)));
      await tester.tap(find.bySemanticsLabel('Pause'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      await _dispose(tester);
    });
  }

  // Largest text size the app allows (main.dart clamps system scaling to 1.2x).
  for (final size in ['small phone', 'small landscape', 'phone landscape']) {
    for (final screen in screens.entries) {
      testWidgets('${screen.key} @ $size, large text', (tester) async {
        await _pumpAt(tester, sizes[size]!, screen.value(), textScale: 1.2);
        expect(tester.takeException(), isNull);
        await _dispose(tester);
      });
    }
  }
}
