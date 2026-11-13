import 'dart:async';

import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../data/match_config.dart';
import '../data/profile.dart';
import '../theme/arena_theme.dart';
import '../widgets/board_art.dart';
import '../widgets/chest_dialog.dart';
import '../widgets/glossy.dart';
import 'academy_screen.dart';
import 'match_screen.dart';
import 'modes_screen.dart';
import 'profile_screen.dart';
import 'settings_sheet.dart';
import 'store_screen.dart';

void pushScreen(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _float.dispose();
    _clock?.cancel();
    super.dispose();
  }

  String _untilMidnight() {
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1);
    final d = next.difference(now);
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final p = Profile.instance;
    return ListenableBuilder(
      listenable: p,
      builder: (context, _) {
        final landscape = context.isLandscape;
        return ArenaScaffold(
          child: Column(
            children: [
              _header(p),
              Expanded(child: LayoutBuilder(builder: (context, c) => landscape ? _landscape(p, c) : _portrait(p, c))),
              _BottomNav(
                compact: landscape,
                onAcademy: () => pushScreen(context, const AcademyScreen()),
                onStore: () => pushScreen(context, const StoreScreen()),
                onTrophies: () => pushScreen(context, const ProfileScreen()),
                onSettings: () => showSettingsSheet(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(Profile p) {
    final (cur, need) = p.levelProgress;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Pressable(
              semanticLabel: 'Open profile',
              onTap: () => pushScreen(context, const ProfileScreen()),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: Gloss.orange.gradient,
                      border: Border.all(color: Arena.rim, width: 2.5),
                    ),
                    alignment: Alignment.center,
                    child: FittedBox(
                      child: Text('${p.level}', style: Arena.display(20, outline: Gloss.orange.outline)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Player One',
                          style: Arena.body(15, weight: FontWeight.w900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: MetalBar(value: cur / need, height: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          CurrencyPill(
            icon: const CoinIcon(size: 24),
            value: p.coins,
            semanticLabel: '${p.coins} coins, open store',
            onTap: () => pushScreen(context, const StoreScreen()),
          ),
          const SizedBox(width: 8),
          CurrencyPill(
            icon: const GemIcon(size: 24),
            value: p.gems,
            semanticLabel: '${p.gems} gems, open store',
            onTap: () => pushScreen(context, const StoreScreen()),
          ),
        ],
      ),
    );
  }

  Widget _title(double size) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('SLING', style: Arena.display(size, outline: const Color(0xFFB4561C))),
      Text(
        'ARENA',
        style: Arena.display(size, color: Arena.gold, outline: const Color(0xFF8A4A0C)),
      ),
      const SizedBox(height: 6),
      Text('FLICK · SLIDE · CLEAR YOUR SIDE', style: Arena.label(11)),
    ],
  );

  Widget _board(Profile p, double height) {
    final playerSkin = Catalog.puck(p.equippedId(StoreCategory.pucks));
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_float.value);
        return Transform.translate(
          offset: Offset(0, -6 + t * 12),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0016)
              ..rotateX(0.75)
              ..rotateZ(-0.06 + t * 0.12),
            child: child,
          ),
        );
      },
      child: MiniBoard(
        board: Catalog.board(p.equippedId(StoreCategory.boards)),
        band: Catalog.band(p.equippedId(StoreCategory.bands)),
        topPuck: Catalog.opponentPuck(playerSkin.id),
        bottomPuck: playerSkin,
        width: height * 0.76,
        height: height,
      ),
    );
  }

  Widget _actions(Profile p) {
    final rung = MatchConfig.tournamentLadder[(p.tournamentRound - 1).clamp(0, 2)];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlossyButton(
          label: 'PLAY',
          icon: Icons.play_arrow_rounded,
          height: 74,
          fontSize: 34,
          onTap: () => pushScreen(context, const ModesScreen()),
        ),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _EventCard(
                  icon: Icons.calendar_month_rounded,
                  tint: Arena.gold,
                  tag: p.dailyAvailable ? _untilMidnight() : 'DONE',
                  title: 'Daily Challenge',
                  subtitle: p.dailyAvailable ? 'Beat Vex in 90s · +150' : 'Back tomorrow',
                  onTap: p.dailyAvailable ? () => startMatch(context, MatchConfig.daily()) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EventCard(
                  icon: Icons.emoji_events_rounded,
                  tint: Arena.tide,
                  tag: 'ROUND ${p.tournamentRound}/3',
                  title: 'Tournament',
                  subtitle: 'Vs ${rung.botName} · ${rung.label}',
                  onTap: () => startMatch(context, MatchConfig.tournament(p.tournamentRound)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ChestStrip(profile: p),
      ],
    );
  }

  Widget _portrait(Profile p, BoxConstraints c) {
    // Everything except the board needs ~440px; the board takes what is left.
    final boardH = (c.maxHeight - 440).clamp(130.0, 300.0);
    return SingleChildScrollView(
      padding: centeredPadding(c.maxWidth, maxContent: 520),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: c.maxHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [const SizedBox(height: 8), _title(50), _board(p, boardH), _actions(p), const SizedBox(height: 12)],
        ),
      ),
    );
  }

  Widget _landscape(Profile p, BoxConstraints c) {
    final boardH = (c.maxHeight - 130).clamp(110.0, 280.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(mainAxisSize: MainAxisSize.min, children: [_title(40), const SizedBox(height: 4), _board(p, boardH)]),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight - 20),
                child: Center(
                  child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: _actions(p)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.icon, required this.tint, required this.tag, required this.title, required this.subtitle, this.onTap});

  final IconData icon;
  final Color tint;
  final String tag;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      enabled: onTap != null,
      semanticLabel: '$title, $subtitle',
      child: Opacity(
        opacity: onTap == null ? 0.6 : 1,
        child: BevelPanel(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: tint, size: 22),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      tag,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: Arena.body(11, weight: FontWeight.w900, color: tint),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Arena.body(15, weight: FontWeight.w900),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Arena.body(12, weight: FontWeight.w700, color: Arena.muted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChestStrip extends StatelessWidget {
  const _ChestStrip({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final ready = profile.chestsReady > 0;
    return BevelPanel(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      borderColor: ready ? Arena.ember : Arena.panelEdge,
      child: Row(
        children: [
          const ChestIcon(size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ready ? 'Chest ready!' : 'Win to fill your chest',
                  style: Arena.body(14, weight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                MetalBar(
                  value: ready ? 1 : profile.chestProgress / Profile.chestGoal,
                  gloss: Gloss.blue,
                  height: 20,
                  label: ready ? '${profile.chestsReady} READY' : '${profile.chestProgress} / ${Profile.chestGoal}',
                ),
              ],
            ),
          ),
          if (ready) ...[
            const SizedBox(width: 10),
            SizedBox(
              width: 86,
              child: GlossyButton(label: 'OPEN', gloss: Gloss.green, height: 46, fontSize: 20, onTap: () => showChestDialog(context)),
            ),
          ],
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.onAcademy,
    required this.onStore,
    required this.onTrophies,
    required this.onSettings,
    this.compact = false,
  });

  final bool compact;

  final VoidCallback onAcademy;
  final VoidCallback onStore;
  final VoidCallback onTrophies;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String label, VoidCallback? onTap, {bool active = false}) {
      final color = active ? Arena.gold : Arena.muted;
      return Expanded(
        child: Pressable(
          onTap: onTap ?? () {},
          semanticLabel: label,
          child: SizedBox(
            height: compact ? 48 : 62,
            child: compact
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color, size: 22),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          label,
                          style: Arena.body(12, weight: FontWeight.w900, color: color),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color, size: 24),
                      const SizedBox(height: 3),
                      FittedBox(
                        child: Text(
                          label,
                          style: Arena.body(10, weight: FontWeight.w900, color: color),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(14, compact ? 2 : 6, 14, compact ? 6 : 12),
      child: BevelPanel(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        radius: 24,
        child: Row(
          children: [
            item(Icons.home_rounded, 'Home', null, active: true),
            item(Icons.school_rounded, 'Academy', onAcademy),
            item(Icons.storefront_rounded, 'Store', onStore),
            item(Icons.emoji_events_rounded, 'Trophies', onTrophies),
            item(Icons.settings_rounded, 'Settings', onSettings),
          ],
        ),
      ),
    );
  }
}
