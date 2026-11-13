import 'package:flutter/material.dart';

import '../data/match_config.dart';
import '../data/profile.dart';
import '../theme/arena_theme.dart';
import '../widgets/glossy.dart';
import 'academy_screen.dart';
import 'home_screen.dart';
import 'match_screen.dart';

class ModesScreen extends StatefulWidget {
  const ModesScreen({super.key});

  @override
  State<ModesScreen> createState() => _ModesScreenState();
}

class _ModesScreenState extends State<ModesScreen> {
  bool _vsAi = true;
  Difficulty _level = Difficulty.normal;
  int _pucks = 5;

  void _start() {
    startMatch(context, MatchConfig(style: _vsAi ? PlayStyle.vsAi : PlayStyle.passAndPlay, difficulty: _level, pucksPerSide: _pucks));
  }

  @override
  Widget build(BuildContext context) {
    final p = Profile.instance;
    final width = context.screen.width;
    final landscape = context.isLandscape;
    return ArenaScaffold(
      glow: Arena.tide,
      child: Column(
        children: [
          const PageHeader(title: 'Choose Mode'),
          Expanded(
            child: ListView(
              padding: centeredPadding(width, maxContent: landscape ? 820 : 640, top: 18, bottom: 12),
              children: [
                _ModeCard(
                  selected: _vsAi,
                  accent: Arena.tide,
                  gloss: Gloss.blue,
                  icon: Icons.smart_toy_rounded,
                  title: 'Vs AI',
                  subtitle: 'Four bots that learn your angles',
                  onTap: () => setState(() => _vsAi = true),
                  footer: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Row(
                      children: [
                        for (final d in Difficulty.values) ...[
                          Expanded(
                            child: _Pill(
                              label: d.label,
                              selected: _vsAi && _level == d,
                              gloss: Gloss.blue,
                              onTap: () => setState(() {
                                _vsAi = true;
                                _level = d;
                              }),
                            ),
                          ),
                          if (d != Difficulty.legend) const SizedBox(width: 6),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ModeCard(
                  selected: !_vsAi,
                  accent: Arena.ember,
                  gloss: Gloss.orange,
                  icon: Icons.people_alt_rounded,
                  title: 'Pass & Play',
                  subtitle: 'Two players, one phone, face to face',
                  onTap: () => setState(() => _vsAi = false),
                ),
                const SizedBox(height: 12),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: width >= 620 ? 4 : 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 138,
                  ),
                  children: [
                    _SmallMode(
                      icon: Icons.emoji_events_rounded,
                      title: 'Tournament',
                      subtitle: 'Round ${p.tournamentRound}/3 · cups & chests',
                      onTap: () => startMatch(context, MatchConfig.tournament(p.tournamentRound)),
                    ),
                    _SmallMode(
                      icon: Icons.timer_rounded,
                      title: 'Time Attack',
                      subtitle: 'Clear $_pucks pucks in ${MatchConfig.timeAttack(_pucks).timeLimit}s',
                      onTap: () => startMatch(context, MatchConfig.timeAttack(_pucks)),
                    ),
                    _SmallMode(
                      icon: Icons.calendar_month_rounded,
                      title: 'Daily Challenge',
                      subtitle: p.dailyAvailable ? 'Beat Vex in 90 seconds' : 'Done · back tomorrow',
                      onTap: p.dailyAvailable ? () => startMatch(context, MatchConfig.daily()) : null,
                    ),
                    _SmallMode(
                      icon: Icons.school_rounded,
                      title: 'Academy',
                      subtitle: '${p.lessonsDone}/4 lessons done',
                      onTap: () => pushScreen(context, const AcademyScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                  decoration: BoxDecoration(color: Arena.inset, borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Pucks per side', style: Arena.body(14, color: Arena.muted), maxLines: 2),
                      ),
                      for (final n in const [3, 5, 7]) ...[
                        SizedBox(
                          width: 52,
                          child: _Pill(label: '$n', selected: _pucks == n, gloss: Gloss.gold, onTap: () => setState(() => _pucks = n)),
                        ),
                        if (n != 7) const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: centeredPadding(width, maxContent: 520, top: 4, bottom: landscape ? 8 : 18),
            child: GlossyButton(
              label: 'START MATCH',
              gloss: Gloss.green,
              height: landscape ? 54 : 68,
              fontSize: landscape ? 24 : 28,
              onTap: _start,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.selected,
    required this.accent,
    required this.gloss,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.footer,
  });

  final bool selected;
  final Color accent;
  final Gloss gloss;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: Arena.panelGradient,
        border: Border.all(color: selected ? accent : Arena.panelEdge, width: selected ? 3 : 2),
        boxShadow: [
          const BoxShadow(color: Color(0xFF0A101C), offset: Offset(0, 4)),
          if (selected) BoxShadow(color: accent.withValues(alpha: 0.25), blurRadius: 18),
        ],
      ),
      child: Column(
        children: [
          Pressable(
            onTap: onTap,
            semanticLabel: '$title. $subtitle',
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    gradient: gloss.gradient,
                    border: Border.all(color: Arena.rim, width: 3),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30, shadows: Arena.outlineShadows(gloss.outline, 2)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Arena.body(19, weight: FontWeight.w900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Arena.body(13, weight: FontWeight.w700, color: Arena.muted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: selected ? 1 : 0,
                  child: Icon(Icons.check_circle_rounded, color: accent, size: 26),
                ),
              ],
            ),
          ),
          ?footer,
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, required this.gloss, required this.onTap});

  final String label;
  final bool selected;
  final Gloss gloss;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: Pressable(
        onTap: onTap,
        semanticLabel: label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: selected ? gloss.gradient : null,
            color: selected ? null : Arena.night,
            border: Border.all(color: selected ? Arena.rim : Arena.track, width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: selected
                  ? Arena.display(15, outline: gloss.outline, letterSpacing: 0.5)
                  : Arena.body(13, weight: FontWeight.w900, color: Arena.muted),
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallMode extends StatelessWidget {
  const _SmallMode({required this.icon, required this.title, required this.subtitle, this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      enabled: onTap != null,
      semanticLabel: '$title. $subtitle',
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: BevelPanel(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Arena.gold, size: 28),
              const Spacer(),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
