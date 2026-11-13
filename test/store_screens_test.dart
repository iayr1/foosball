// Renders clean, full-resolution app screens for the Play Store listing.
// Run:  flutter test test/store_screens_test.dart --update-goldens --tags store
// Output: store_assets/raw/*.png (1080 x 2400). Skipped in normal test runs.
@Tags(['store'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foosball/data/catalog.dart';
import 'package:foosball/data/match_config.dart';
import 'package:foosball/data/profile.dart';
import 'package:foosball/screens/home_screen.dart';
import 'package:foosball/screens/match_screen.dart';
import 'package:foosball/screens/modes_screen.dart';
import 'package:foosball/screens/profile_screen.dart';
import 'package:foosball/screens/result_screen.dart';
import 'package:foosball/screens/store_screen.dart';
import 'package:foosball/theme/arena_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await _loadFont('LilitaOne', 'assets/fonts/LilitaOne-Regular.ttf');
    await _loadFont('Nunito', 'assets/fonts/Nunito.ttf');
    await _loadFont('MaterialIcons', '${Platform.environment['FLUTTER_ROOT'] ?? 'C:/Users/mayur/flutter'}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');

    // A believable mid-game profile for the listing.
    final p = Profile.instance
      ..coins = 4820
      ..gems = 145
      ..xp = 3400
      ..matches = 148
      ..wins = 93
      ..bestStreak = 9
      ..fastestWin = 31
      ..legendWins = 2
      ..bestCombo = 3
      ..tournamentsWon = 4
      ..tournamentRound = 2
      ..chestProgress = 3
      ..lessonsDone = 4
      ..seenIntro = true
      ..aimGuide = true;
    p.owned.addAll(['gold', 'jade', 'frost', 'midnight', 'neon', 'spark', 'comet', 'ruby']);
    p.equipped[StoreCategory.pucks] = 'gold';
    p.equipped[StoreCategory.boards] = 'walnut';
    p.equipped[StoreCategory.bands] = 'neon';
    p.equipped[StoreCategory.effects] = 'spark';
    p.achievements.addAll(['first_win', 'rookie', 'sweep', 'combo', 'streak', 'champion', 'scholar']);
  });

  final shots = <String, Widget Function()>{
    '1_home': () => const HomeScreen(),
    '2_match': () => const MatchScreen(config: MatchConfig(style: PlayStyle.vsAi, difficulty: Difficulty.hard)),
    '3_modes': () => const ModesScreen(),
    '4_victory': () => ResultScreen(
          config: const MatchConfig(style: PlayStyle.vsAi, difficulty: Difficulty.legend),
          playerWon: true,
          summary: RewardSummary(
            coins: 230,
            gems: 0,
            xp: 60,
            stars: 3,
            leveledUp: true,
            newLevel: 9,
            chestEarned: true,
            unlocked: [Profile.allAchievements.firstWhere((a) => a.id == 'legend')],
            tournamentWon: false,
          ),
          seconds: 52,
          playerSent: 5,
          opponentSent: 2,
        ),
    '5_store': () => const StoreScreen(),
    '6_profile': () => const ProfileScreen(),
  };

  for (final entry in shots.entries) {
    testWidgets('store screen ${entry.key}', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      if (entry.key == '4_victory') Profile.instance.chestsReady = 0;

      await tester.pumpWidget(
        RepaintBoundary(
          key: const ValueKey('shot'),
          child: MaterialApp(debugShowCheckedModeBanner: false, theme: Arena.theme(), home: entry.value()),
        ),
      );
      // Let images decode and entry animations finish.
      await tester.runAsync(() async {
        for (final e in find.byType(Image).evaluate()) {
          await precacheImage((e.widget as Image).image, e);
        }
      });
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }
      await expectLater(find.byKey(const ValueKey('shot')), matchesGoldenFile('../store_assets/raw/${entry.key}.png'));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 6));
    });
  }
}
