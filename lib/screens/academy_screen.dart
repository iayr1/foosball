import 'package:flutter/material.dart';

import '../data/match_config.dart';
import '../data/profile.dart';
import '../theme/arena_theme.dart';
import '../widgets/glossy.dart';
import 'match_screen.dart';

class Lesson {
  final String title;
  final String tip;
  final int pucks;
  final IconData icon;
  const Lesson(this.title, this.tip, this.pucks, this.icon);
}

const lessons = [
  Lesson('Aim Basics', 'Drag a puck back like a slingshot and let go. Pull further for more power.', 3, Icons.ads_click_rounded),
  Lesson(
    'Thread the Gap',
    'Only the gap in the wall lets pucks through. Line up straight shots from the middle.',
    5,
    Icons.straighten_rounded,
  ),
  Lesson('Bank Shots', 'Blocked? Bounce off the side rails into the gap. Medium power works best.', 5, Icons.call_split_rounded),
  Lesson('Combo Rush', 'Hit one puck into another to push two through at once for a combo.', 7, Icons.bolt_rounded),
];

class AcademyScreen extends StatelessWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Profile.instance;
    final width = context.screen.width;
    return ArenaScaffold(
      glow: Arena.gold,
      child: Column(
        children: [
          const PageHeader(title: 'Academy'),
          Padding(
            padding: centeredPadding(width, top: 14),
            child: Text(
              'Solo drills with no opponent. Clear every puck to finish a lesson and earn coins.',
              style: Arena.body(14, weight: FontWeight.w700, color: Arena.muted),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: p,
              builder: (context, _) => ListView.separated(
                padding: centeredPadding(width, top: 16, bottom: 20),
                itemCount: lessons.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final l = lessons[i];
                  final done = i < p.lessonsDone;
                  final locked = i > p.lessonsDone;
                  return Opacity(
                    opacity: locked ? 0.55 : 1,
                    child: BevelPanel(
                      borderColor: done ? Arena.gold : Arena.panelEdge,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: (done ? Gloss.gold : Gloss.blue).gradient,
                                  border: Border.all(color: Arena.rim, width: 2.5),
                                ),
                                child: Icon(done ? Icons.check_rounded : l.icon, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('LESSON ${i + 1}', style: Arena.label(11)),
                                    Text(
                                      l.title,
                                      style: Arena.body(17, weight: FontWeight.w900),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (locked) const Icon(Icons.lock_rounded, color: Arena.muted),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l.tip,
                            style: Arena.body(13, weight: FontWeight.w700, color: Arena.muted),
                          ),
                          const SizedBox(height: 12),
                          GlossyButton(
                            label: done ? 'REPLAY' : 'START',
                            gloss: done ? Gloss.blue : Gloss.green,
                            height: 48,
                            fontSize: 20,
                            enabled: !locked,
                            onTap: locked
                                ? null
                                : () => startMatch(context, MatchConfig(style: PlayStyle.practice, pucksPerSide: l.pucks, lesson: i)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
