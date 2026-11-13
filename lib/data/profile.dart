import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog.dart';
import 'match_config.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final int target;
  final int coins;
  final int gems;
  final int Function(Profile p) progress;

  const Achievement(this.id, this.title, this.description, this.target, this.progress, {this.coins = 0, this.gems = 0});
}

class MatchResult {
  final MatchConfig config;
  final bool playerWon;
  final int seconds;
  final int opponentCleared;
  final int bestCombo;

  const MatchResult({
    required this.config,
    required this.playerWon,
    required this.seconds,
    required this.opponentCleared,
    required this.bestCombo,
  });
}

class RewardSummary {
  final int coins;
  final int gems;
  final int xp;
  final int stars;
  final bool leveledUp;
  final int newLevel;
  final bool chestEarned;
  final List<Achievement> unlocked;
  final bool tournamentWon;

  const RewardSummary({
    required this.coins,
    required this.gems,
    required this.xp,
    required this.stars,
    required this.leveledUp,
    required this.newLevel,
    required this.chestEarned,
    required this.unlocked,
    required this.tournamentWon,
  });
}

class ChestReward {
  final int coins;
  final int gems;
  final StoreItem? item;
  const ChestReward(this.coins, this.gems, this.item);
}

/// Everything the player has earned, owns and prefers. Saved on device.
class Profile extends ChangeNotifier {
  Profile._();
  static final Profile instance = Profile._();

  static const chestGoal = 5;

  SharedPreferences? _prefs;

  int coins = 500;
  int gems = 20;
  int xp = 0;
  Set<String> owned = {...Catalog.defaults.values, 'tide'};
  Map<StoreCategory, String> equipped = Map.of(Catalog.defaults);

  int matches = 0;
  int wins = 0;
  int streak = 0;
  int bestStreak = 0;
  int? fastestWin;
  int legendWins = 0;
  int cleanSweeps = 0;
  int bestCombo = 0;
  int dailyWins = 0;
  String? lastDailyWin;
  int tournamentRound = 1;
  int tournamentsWon = 0;
  int chestProgress = 0;
  int chestsReady = 0;
  int lessonsDone = 0;
  Set<String> achievements = {};

  bool sound = true;
  bool haptics = true;
  bool aimGuide = true;
  bool seenIntro = false;

  static final List<Achievement> allAchievements = [
    Achievement('first_win', 'First Flick', 'Win your first match', 1, (p) => p.wins, coins: 50),
    Achievement('rookie', 'Bank Shot Rookie', 'Win 10 matches', 10, (p) => p.wins, coins: 150),
    Achievement('veteran', 'Arena Veteran', 'Win 50 matches', 50, (p) => p.wins, coins: 500, gems: 20),
    Achievement('sweep', 'Clean Sweep', 'Win without the bot clearing a puck', 1, (p) => p.cleanSweeps, coins: 120),
    Achievement('speed', 'Speed Demon', 'Win a match in 30 seconds', 1, (p) => (p.fastestWin ?? 999) <= 30 ? 1 : 0, coins: 150),
    Achievement('combo', 'Combo King', 'Send 3 pucks with one shot', 3, (p) => p.bestCombo, coins: 150, gems: 5),
    Achievement('streak', 'On Fire', 'Win 5 in a row', 5, (p) => p.bestStreak, coins: 200, gems: 5),
    Achievement('legend', 'Legend Slayer', 'Beat Nova on Legend 3 times', 3, (p) => p.legendWins, coins: 300, gems: 15),
    Achievement('champion', 'Champion', 'Win a tournament', 1, (p) => p.tournamentsWon, coins: 400, gems: 20),
    Achievement('daily', 'Daily Devotee', 'Win 3 daily challenges', 3, (p) => p.dailyWins, coins: 200, gems: 10),
    Achievement('scholar', 'Scholar', 'Finish all 4 Academy lessons', 4, (p) => p.lessonsDone, coins: 120),
    Achievement('collector', 'Collector', 'Own 10 store items', 10, (p) => p.owned.length, coins: 250, gems: 10),
  ];

  // ---------- Level ----------
  static int xpForLevel(int level) => 200 + level * 100;

  int get level {
    var lvl = 1;
    var remaining = xp;
    while (remaining >= xpForLevel(lvl)) {
      remaining -= xpForLevel(lvl);
      lvl++;
    }
    return lvl;
  }

  /// XP earned inside the current level, and needed for the next one.
  (int, int) get levelProgress {
    var lvl = 1;
    var remaining = xp;
    while (remaining >= xpForLevel(lvl)) {
      remaining -= xpForLevel(lvl);
      lvl++;
    }
    return (remaining, xpForLevel(lvl));
  }

  String get rankName {
    final l = level;
    if (l >= 25) return 'LEGEND';
    if (l >= 18) return 'DIAMOND';
    if (l >= 12) return 'GOLD';
    if (l >= 6) return 'SILVER';
    return 'BRONZE';
  }

  int get winRate => matches == 0 ? 0 : ((wins / matches) * 100).round();

  bool get dailyAvailable => lastDailyWin != _today();

  static String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  // ---------- Persistence ----------
  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString('arena_profile_v1');
    if (raw == null) return;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      coins = m['coins'] ?? coins;
      gems = m['gems'] ?? gems;
      xp = m['xp'] ?? xp;
      owned = {...owned, ...List<String>.from(m['owned'] ?? const [])};
      final eq = Map<String, dynamic>.from(m['equipped'] ?? const {});
      for (final c in StoreCategory.values) {
        final id = eq[c.name];
        if (id is String && owned.contains(id)) equipped[c] = id;
      }
      matches = m['matches'] ?? 0;
      wins = m['wins'] ?? 0;
      streak = m['streak'] ?? 0;
      bestStreak = m['bestStreak'] ?? 0;
      fastestWin = m['fastestWin'];
      legendWins = m['legendWins'] ?? 0;
      cleanSweeps = m['cleanSweeps'] ?? 0;
      bestCombo = m['bestCombo'] ?? 0;
      dailyWins = m['dailyWins'] ?? 0;
      lastDailyWin = m['lastDailyWin'];
      tournamentRound = m['tournamentRound'] ?? 1;
      tournamentsWon = m['tournamentsWon'] ?? 0;
      chestProgress = m['chestProgress'] ?? 0;
      chestsReady = m['chestsReady'] ?? 0;
      lessonsDone = m['lessonsDone'] ?? 0;
      achievements = Set<String>.from(m['achievements'] ?? const []);
      sound = m['sound'] ?? true;
      haptics = m['haptics'] ?? true;
      aimGuide = m['aimGuide'] ?? true;
      seenIntro = m['seenIntro'] ?? false;
    } catch (_) {
      // Corrupt save: keep defaults.
    }
  }

  void _save() {
    notifyListeners();
    _prefs?.setString(
      'arena_profile_v1',
      jsonEncode({
        'coins': coins,
        'gems': gems,
        'xp': xp,
        'owned': owned.toList(),
        'equipped': {for (final e in equipped.entries) e.key.name: e.value},
        'matches': matches,
        'wins': wins,
        'streak': streak,
        'bestStreak': bestStreak,
        'fastestWin': fastestWin,
        'legendWins': legendWins,
        'cleanSweeps': cleanSweeps,
        'bestCombo': bestCombo,
        'dailyWins': dailyWins,
        'lastDailyWin': lastDailyWin,
        'tournamentRound': tournamentRound,
        'tournamentsWon': tournamentsWon,
        'chestProgress': chestProgress,
        'chestsReady': chestsReady,
        'lessonsDone': lessonsDone,
        'achievements': achievements.toList(),
        'sound': sound,
        'haptics': haptics,
        'aimGuide': aimGuide,
        'seenIntro': seenIntro,
      }),
    );
  }

  // ---------- Settings ----------
  void setSound(bool v) {
    sound = v;
    _save();
  }

  void setHaptics(bool v) {
    haptics = v;
    _save();
  }

  void setAimGuide(bool v) {
    aimGuide = v;
    _save();
  }

  void markIntroSeen() {
    seenIntro = true;
    _save();
  }

  // ---------- Store ----------
  bool owns(StoreItem item) => owned.contains(item.id);
  bool isEquipped(StoreItem item) => equipped[item.category] == item.id;
  bool canAfford(StoreItem item) => item.costsGems ? gems >= item.price : coins >= item.price;

  bool buy(StoreItem item) {
    if (owns(item) || !canAfford(item)) return false;
    if (item.costsGems) {
      gems -= item.price;
    } else {
      coins -= item.price;
    }
    owned.add(item.id);
    equipped[item.category] = item.id;
    _checkAchievements();
    _save();
    return true;
  }

  void equip(StoreItem item) {
    if (!owns(item)) return;
    equipped[item.category] = item.id;
    _save();
  }

  String equippedId(StoreCategory c) => equipped[c] ?? Catalog.defaults[c]!;

  // ---------- Chests ----------
  ChestReward openChest() {
    if (chestsReady <= 0) return const ChestReward(0, 0, null);
    chestsReady--;
    final rnd = math.Random();
    final c = 80 + rnd.nextInt(121);
    final g = rnd.nextInt(3) == 0 ? 5 + rnd.nextInt(6) : 0;
    StoreItem? item;
    final locked = Catalog.items.where((i) => !owned.contains(i.id) && i.rarity != Rarity.legendary).toList();
    if (locked.isNotEmpty && rnd.nextInt(4) == 0) {
      item = locked[rnd.nextInt(locked.length)];
      owned.add(item.id);
    }
    coins += c;
    gems += g;
    _checkAchievements();
    _save();
    return ChestReward(c, g, item);
  }

  // ---------- Matches ----------
  RewardSummary recordMatch(MatchResult r) {
    final beforeLevel = level;
    var c = 0;
    var g = 0;
    var x = 0;
    var stars = 0;
    var chestEarned = false;
    var tournamentWon = false;

    final competitive = r.config.style == PlayStyle.vsAi || r.config.style == PlayStyle.daily || r.config.style == PlayStyle.tournament;

    if (r.bestCombo > bestCombo) bestCombo = r.bestCombo;

    if (r.playerWon) {
      stars = r.seconds <= 60 ? 3 : (r.seconds <= 120 ? 2 : 1);
    }

    switch (r.config.style) {
      case PlayStyle.passAndPlay:
        matches++;
        c = 20;
        x = 10;
      case PlayStyle.practice:
        if (r.playerWon) {
          final lesson = (r.config.lesson ?? 0) + 1;
          if (lesson > lessonsDone) lessonsDone = lesson;
          c = 30;
          x = 15;
        }
      case PlayStyle.timeAttack:
        if (r.playerWon) {
          final left = (r.config.timeLimit ?? 0) - r.seconds;
          c = 50 + left * 2;
          x = 30;
        } else {
          c = 10;
          x = 5;
        }
      case PlayStyle.vsAi:
      case PlayStyle.daily:
      case PlayStyle.tournament:
        break;
    }

    if (competitive) {
      matches++;
      if (r.playerWon) {
        wins++;
        streak++;
        bestStreak = math.max(bestStreak, streak);
        if (fastestWin == null || r.seconds < fastestWin!) fastestWin = r.seconds;
        if (r.config.difficulty == Difficulty.legend) legendWins++;
        if (r.opponentCleared == 0) cleanSweeps++;
        c = r.config.difficulty.winCoins + stars * 10;
        x = r.config.difficulty.winXp;
        chestProgress++;
        if (chestProgress >= chestGoal) {
          chestProgress = 0;
          chestsReady++;
          chestEarned = true;
        }
        if (r.config.style == PlayStyle.daily && dailyAvailable) {
          dailyWins++;
          lastDailyWin = _today();
          c += 150;
          g += 5;
        }
        if (r.config.style == PlayStyle.tournament) {
          if (r.config.tournamentRound >= 3) {
            tournamentsWon++;
            tournamentRound = 1;
            tournamentWon = true;
            c += 500;
            g += 15;
            chestsReady++;
            chestEarned = true;
          } else {
            tournamentRound = r.config.tournamentRound + 1;
          }
        }
      } else {
        streak = 0;
        c = 20;
        x = 10;
        if (r.config.style == PlayStyle.tournament) tournamentRound = 1;
      }
    }

    coins += c;
    gems += g;
    xp += x;
    final unlocked = _checkAchievements();
    for (final a in unlocked) {
      c += a.coins;
      g += a.gems;
    }
    _save();

    return RewardSummary(
      coins: c,
      gems: g,
      xp: x,
      stars: stars,
      leveledUp: level > beforeLevel,
      newLevel: level,
      chestEarned: chestEarned,
      unlocked: unlocked,
      tournamentWon: tournamentWon,
    );
  }

  /// Unlocks any finished achievements, pays their rewards, returns the new ones.
  List<Achievement> _checkAchievements() {
    final fresh = <Achievement>[];
    for (final a in allAchievements) {
      if (achievements.contains(a.id)) continue;
      if (a.progress(this) >= a.target) {
        achievements.add(a.id);
        coins += a.coins;
        gems += a.gems;
        fresh.add(a);
      }
    }
    return fresh;
  }
}
