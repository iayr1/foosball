import 'package:flutter/material.dart';

class AcademyScreen extends StatelessWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ModeSecondaryScaffold(
      title: 'Academy',
      subtitle: 'Sharpen your sling puck skills',
      icon: Icons.school_rounded,
      accent: const Color(0xFF4A9BFF),
      sections: const [
        _FeatureTileData(
          title: 'Aim Basics',
          description: 'Learn power, angle, and release timing with guided drills.',
          icon: Icons.track_changes_rounded,
        ),
        _FeatureTileData(
          title: 'Defense Practice',
          description: 'Train your blocking and quick-return reaction speed.',
          icon: Icons.shield_rounded,
        ),
        _FeatureTileData(
          title: 'Advanced Combos',
          description: 'Master bank shots and rapid-fire puck control patterns.',
          icon: Icons.bolt_rounded,
        ),
      ],
    );
  }
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ModeSecondaryScaffold(
      title: 'Achievements',
      subtitle: 'Track milestones and unlock bragging rights',
      icon: Icons.emoji_events_rounded,
      accent: const Color(0xFFFFA43C),
      sections: const [
        _FeatureTileData(
          title: 'Rookie Winner',
          description: 'Win your first match in any game mode.',
          icon: Icons.verified_rounded,
          tag: 'Unlocked',
        ),
        _FeatureTileData(
          title: 'Perfect Sweep',
          description: 'Clear your side in under 20 seconds.',
          icon: Icons.flash_on_rounded,
          tag: 'In Progress',
        ),
        _FeatureTileData(
          title: 'Legend Arena',
          description: 'Win 50 total matches against any opponent.',
          icon: Icons.military_tech_rounded,
          tag: 'Locked',
        ),
      ],
    );
  }
}

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ModeSecondaryScaffold(
      title: 'Store',
      subtitle: 'Customize your arena style',
      icon: Icons.store_rounded,
      accent: const Color(0xFF42D29D),
      sections: const [
        _FeatureTileData(
          title: 'Neon Arena Skin',
          description: 'A futuristic board style with glowing edges.',
          icon: Icons.auto_awesome_rounded,
          tag: '250 Coins',
        ),
        _FeatureTileData(
          title: 'Golden Puck',
          description: 'Premium puck trail with smooth spark effects.',
          icon: Icons.circle_rounded,
          tag: '400 Coins',
        ),
        _FeatureTileData(
          title: 'Retro Sound Pack',
          description: 'Classic arcade sounds for shots and collisions.',
          icon: Icons.graphic_eq_rounded,
          tag: '120 Coins',
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ModeSecondaryScaffold(
      title: 'Settings',
      subtitle: 'Tune your gameplay experience',
      icon: Icons.settings_rounded,
      accent: const Color(0xFF9D7CFF),
      sections: const [
        _FeatureTileData(
          title: 'Sound',
          description: 'Toggle music and effects volume for gameplay.',
          icon: Icons.volume_up_rounded,
        ),
        _FeatureTileData(
          title: 'Controls',
          description: 'Adjust touch sensitivity and drag behavior.',
          icon: Icons.touch_app_rounded,
        ),
        _FeatureTileData(
          title: 'Graphics',
          description: 'Choose performance mode or quality mode.',
          icon: Icons.high_quality_rounded,
        ),
      ],
    );
  }
}

class _ModeSecondaryScaffold extends StatelessWidget {
  const _ModeSecondaryScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.sections,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<_FeatureTileData> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF11100F), Color(0xFF21150F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [accent.withOpacity(0.3), const Color(0x33101010)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: accent.withOpacity(0.45)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: accent.withOpacity(0.22),
                        child: Icon(icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: sections.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      return _FeatureTile(section: section, accent: accent);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.section, required this.accent});

  final _FeatureTileData section;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xAA121212),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: accent.withOpacity(0.16),
            ),
            child: Icon(section.icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(section.description, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          if (section.tag != null)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: accent.withOpacity(0.24),
              ),
              child: Text(
                section.tag!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeatureTileData {
  const _FeatureTileData({
    required this.title,
    required this.description,
    required this.icon,
    this.tag,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? tag;
}
