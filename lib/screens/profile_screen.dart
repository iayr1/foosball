import 'package:flutter/material.dart';

import '../data/profile.dart';
import '../theme/arena_theme.dart';
import '../widgets/glossy.dart';
import 'settings_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Profile.instance;
    return ListenableBuilder(
      listenable: p,
      builder: (context, _) {
        final (cur, need) = p.levelProgress;
        final fastest = p.fastestWin;
        final width = context.screen.width;
        return ArenaScaffold(
          glow: Arena.tide,
          child: Column(
            children: [
              const PageHeader(title: 'Profile'),
              Expanded(
                child: ListView(
                  padding: centeredPadding(width, maxContent: 700, top: 18, bottom: 24),
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: Gloss.orange.gradient,
                            border: Border.all(color: Arena.rim, width: 4),
                            boxShadow: const [BoxShadow(color: Arena.dropEdge, offset: Offset(0, 5))],
                          ),
                          alignment: Alignment.center,
                          child: Text('${p.level}', style: Arena.display(34, outline: Gloss.orange.outline)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Player One',
                                style: Arena.body(20, weight: FontWeight.w900),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(color: const Color(0xFF3A2A12), borderRadius: BorderRadius.circular(8)),
                                    child: Text(p.rankName, style: Arena.label(11, color: Arena.gold)),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text('Level ${p.level}', style: Arena.body(12, color: Arena.muted), maxLines: 1),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              MetalBar(value: cur / need, label: '$cur / $need XP', height: 22),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _Stat(value: '${p.matches}', label: 'Matches'),
                        const SizedBox(width: 8),
                        _Stat(value: '${p.winRate}%', label: 'Win rate', color: Arena.gold),
                        const SizedBox(width: 8),
                        _Stat(value: '${p.bestStreak}', label: 'Best streak'),
                        const SizedBox(width: 8),
                        _Stat(
                          value: fastest == null ? '–' : '${fastest ~/ 60}:${(fastest % 60).toString().padLeft(2, '0')}',
                          label: 'Fastest',
                          color: Arena.tide,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Stat(value: '${p.wins}', label: 'Wins'),
                        const SizedBox(width: 8),
                        _Stat(value: '${p.tournamentsWon}', label: 'Cups', color: Arena.gold),
                        const SizedBox(width: 8),
                        _Stat(value: 'x${p.bestCombo}', label: 'Best combo'),
                        const SizedBox(width: 8),
                        _Stat(value: '${p.legendWins}', label: 'Legend wins', color: Arena.rose),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Achievements', style: Arena.body(17, weight: FontWeight.w900)),
                        ),
                        Text('${p.achievements.length} / ${Profile.allAchievements.length}', style: Arena.body(13, color: Arena.muted)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (final a in Profile.allAchievements) ...[_AchievementRow(achievement: a, profile: p), const SizedBox(height: 8)],
                    const SizedBox(height: 14),
                    Text('Settings', style: Arena.body(17, weight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    SettingsToggles(profile: p),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.color = Arena.chalk});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: Arena.panelGradient,
          border: Border.all(color: Arena.panelEdge, width: 2),
        ),
        child: Column(
          children: [
            FittedBox(
              child: Text(value, style: Arena.display(22, color: color)),
            ),
            const SizedBox(height: 2),
            FittedBox(
              child: Text(label, style: Arena.body(10, color: Arena.muted)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({required this.achievement, required this.profile});
  final Achievement achievement;
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final a = achievement;
    final done = profile.achievements.contains(a.id);
    final prog = a.progress(profile).clamp(0, a.target);
    return Semantics(
      label: '${a.title}. ${a.description}. ${done ? 'Unlocked' : '$prog of ${a.target}'}',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: Arena.panelGradient,
            border: Border.all(color: done ? Arena.gold.withValues(alpha: 0.7) : Arena.panelEdge, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: done ? Gloss.gold.gradient : null,
                  color: done ? null : Arena.inset,
                  border: Border.all(color: done ? Arena.rim : Arena.track, width: 2),
                ),
                child: Icon(Icons.military_tech_rounded, color: done ? Colors.white : Arena.dim, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            a.title,
                            style: Arena.body(14, weight: FontWeight.w900),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(done ? 'Done' : '$prog / ${a.target}', style: Arena.body(12, color: done ? Arena.gold : Arena.muted)),
                      ],
                    ),
                    Text(
                      a.description,
                      style: Arena.body(12, weight: FontWeight.w700, color: Arena.muted),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: prog / a.target,
                        minHeight: 6,
                        backgroundColor: Arena.track,
                        valueColor: AlwaysStoppedAnimation(done ? Arena.gold : Arena.tide),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  if (a.coins > 0)
                    Row(
                      children: [
                        const CoinIcon(size: 14),
                        const SizedBox(width: 3),
                        Text('${a.coins}', style: Arena.body(11)),
                      ],
                    ),
                  if (a.gems > 0)
                    Row(
                      children: [
                        const GemIcon(size: 14),
                        const SizedBox(width: 3),
                        Text('${a.gems}', style: Arena.body(11)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
