import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/match_config.dart';
import '../data/profile.dart';
import '../theme/arena_theme.dart';
import '../widgets/chest_dialog.dart';
import '../widgets/glossy.dart';
import 'academy_screen.dart';
import 'match_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.config,
    required this.playerWon,
    required this.summary,
    required this.seconds,
    required this.playerSent,
    required this.opponentSent,
  });

  final MatchConfig config;
  final bool playerWon;
  final RewardSummary summary;
  final int seconds;
  final int playerSent;
  final int opponentSent;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  late final AnimationController _confetti = AnimationController(vsync: this, duration: const Duration(seconds: 4));

  MatchConfig get config => widget.config;
  bool get won => widget.playerWon;
  bool get duo => config.style == PlayStyle.passAndPlay;

  @override
  void initState() {
    super.initState();
    if (won || duo) _confetti.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    _confetti.dispose();
    super.dispose();
  }

  String get _title {
    if (duo) return won ? 'PLAYER 1 WINS' : 'PLAYER 2 WINS';
    if (widget.summary.tournamentWon) return 'CHAMPION!';
    if (won) return config.style == PlayStyle.practice ? 'LESSON DONE' : 'VICTORY';
    if (config.timeLimit != null) return "TIME'S UP";
    return 'DEFEAT';
  }

  String get _subtitle {
    final t = '${widget.seconds ~/ 60}:${(widget.seconds % 60).toString().padLeft(2, '0')}';
    return switch (config.style) {
      PlayStyle.passAndPlay => 'Match time $t',
      PlayStyle.practice => won ? '${lessons[config.lesson ?? 0].title} cleared in $t' : 'Keep practising!',
      PlayStyle.timeAttack =>
        won ? 'All ${config.pucksPerSide} pucks cleared in $t' : 'Cleared ${widget.playerSent} of ${config.pucksPerSide}',
      _ =>
        won
            ? 'You beat ${config.difficulty.botName} · ${config.difficulty.label} in $t'
            : '${config.difficulty.botName} cleared their side first',
    };
  }

  Gloss get _bannerGloss => won || duo ? Gloss.gold : Gloss.blue;

  void _primary() {
    if (config.style == PlayStyle.tournament && won && !widget.summary.tournamentWon) {
      startMatch(context, MatchConfig.tournament(Profile.instance.tournamentRound), replace: true);
      return;
    }
    if (config.style == PlayStyle.tournament) {
      startMatch(context, MatchConfig.tournament(Profile.instance.tournamentRound), replace: true);
      return;
    }
    if (config.style == PlayStyle.practice && won && (config.lesson ?? 0) < lessons.length - 1) {
      final next = (config.lesson ?? 0) + 1;
      startMatch(context, MatchConfig(style: PlayStyle.practice, pucksPerSide: lessons[next].pucks, lesson: next), replace: true);
      return;
    }
    if (config.style == PlayStyle.daily && !Profile.instance.dailyAvailable) {
      Navigator.of(context).pop();
      return;
    }
    startMatch(context, config, replace: true);
  }

  String get _primaryLabel {
    if (config.style == PlayStyle.tournament) {
      if (widget.summary.tournamentWon) return 'NEW CUP';
      return won ? 'NEXT ROUND' : 'RESTART CUP';
    }
    if (config.style == PlayStyle.practice && won && (config.lesson ?? 0) < lessons.length - 1) return 'NEXT LESSON';
    if (config.style == PlayStyle.daily && !Profile.instance.dailyAvailable) return 'DONE';
    return won ? 'PLAY AGAIN' : 'RETRY';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    final p = Profile.instance;
    return ArenaScaffold(
      glow: won || duo ? Arena.gold : Arena.tide,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confetti,
                builder: (context, _) => CustomPaint(painter: _ConfettiPainter(_confetti.value)),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              padding: centeredPadding(c.maxWidth, maxContent: 560),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight),
                child: Column(
                  children: [
                    SizedBox(height: c.maxHeight < 500 ? 12 : 28),
                    if (!duo && config.style != PlayStyle.passAndPlay)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (var i = 0; i < 3; i++)
                            _pop(
                              0.1 + i * 0.15,
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: StarIcon(size: i == 1 ? 66 : 50, filled: i < s.stars),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 14),
                    _pop(0, _Banner(text: _title, gloss: _bannerGloss)),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle,
                      textAlign: TextAlign.center,
                      style: Arena.body(14, color: Arena.muted),
                    ),
                    const SizedBox(height: 18),
                    if (!config.isSolo)
                      _pop(
                        0.3,
                        BevelPanel(
                          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _score(widget.playerSent, duo ? 'PLAYER 1' : 'YOU', Arena.ember),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text('–', style: Arena.display(26, color: Arena.dim)),
                              ),
                              _score(widget.opponentSent, duo ? 'PLAYER 2' : config.difficulty.botName.toUpperCase(), Arena.tide),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _pop(
                      0.45,
                      Row(
                        children: [
                          Expanded(
                            child: _RewardTile(icon: const CoinIcon(size: 36), value: '+${s.coins}', label: 'Coins'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _RewardTile(
                              icon: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: Gloss.blue.gradient,
                                  border: Border.all(color: Arena.rim, width: 2),
                                ),
                                alignment: Alignment.center,
                                child: Text('XP', style: Arena.display(13, outline: Gloss.blue.outline, letterSpacing: 0)),
                              ),
                              value: '+${s.xp}',
                              label: s.leveledUp ? 'Level ${s.newLevel}!' : 'Experience',
                              highlight: s.leveledUp,
                            ),
                          ),
                          if (s.gems > 0) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: _RewardTile(icon: const GemIcon(size: 36), value: '+${s.gems}', label: 'Gems'),
                            ),
                          ] else if (p.chestsReady > 0) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: ListenableBuilder(
                                listenable: p,
                                builder: (context, _) => Pressable(
                                  onTap: p.chestsReady > 0 ? () => showChestDialog(context) : null,
                                  semanticLabel: 'Open chest',
                                  child: _RewardTile(
                                    icon: const ChestIcon(size: 40),
                                    value: p.chestsReady > 0 ? 'Chest' : 'Opened',
                                    label: p.chestsReady > 0 ? 'Tap to open' : 'Collected',
                                    highlight: p.chestsReady > 0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    for (final a in s.unlocked) ...[
                      const SizedBox(height: 10),
                      _pop(
                        0.6,
                        BevelPanel(
                          padding: const EdgeInsets.all(12),
                          borderColor: Arena.gold,
                          child: Row(
                            children: [
                              const Icon(Icons.military_tech_rounded, color: Arena.gold, size: 32),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ACHIEVEMENT UNLOCKED', style: Arena.label(10, color: Arena.gold)),
                                    Text(a.title, style: Arena.body(15, weight: FontWeight.w900)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    _pop(
                      0.7,
                      Column(
                        children: [
                          GlossyButton(label: _primaryLabel, gloss: Gloss.green, height: 66, fontSize: 26, onTap: _primary),
                          const SizedBox(height: 12),
                          GlossyButton(
                            label: 'HOME',
                            gloss: Gloss.blue,
                            height: 54,
                            fontSize: 20,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _score(int v, String label, Color color) => Column(
    children: [
      Text('$v', style: Arena.display(38, color: color)),
      Text(label, style: Arena.label(10)),
    ],
  );

  Widget _pop(double start, Widget child) {
    final a = CurvedAnimation(
      parent: _intro,
      curve: Interval(start, math.min(1, start + 0.35), curve: Curves.easeOutBack),
    );
    return AnimatedBuilder(
      animation: a,
      builder: (context, c) => Opacity(
        opacity: a.value.clamp(0, 1),
        child: Transform.scale(scale: 0.6 + 0.4 * a.value, child: c),
      ),
      child: child,
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.gloss});
  final String text;
  final Gloss gloss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gloss.gradient,
        border: Border.all(color: Arena.rim, width: 4),
        boxShadow: const [
          BoxShadow(color: Arena.dropEdge, offset: Offset(0, 6)),
          BoxShadow(color: Color(0x88000000), blurRadius: 26, offset: Offset(0, 14)),
        ],
      ),
      child: FittedBox(
        child: Text(text, style: Arena.display(46, outline: gloss.outline)),
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({required this.icon, required this.value, required this.label, this.highlight = false});
  final Widget icon;
  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return BevelPanel(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      borderColor: highlight ? Arena.ember : Arena.panelEdge,
      child: Column(
        children: [
          SizedBox(height: 42, child: Center(child: icon)),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(value, style: Arena.body(17, weight: FontWeight.w900)),
          ),
          Text(
            label,
            style: Arena.body(11, color: highlight ? Arena.gold : Arena.muted),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);
  final double t;

  static const _colors = [Color(0xFFFFB547), Color(0xFF3DD6F5), Color(0xFFFF8A3D), Color(0xFFF3F1EA), Color(0xFF9467F0), Color(0xFF5ED43E)];

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final rnd = math.Random(7);
    final paint = Paint();
    for (var i = 0; i < 70; i++) {
      final x0 = rnd.nextDouble() * size.width;
      final speed = 0.6 + rnd.nextDouble() * 0.8;
      final y = -20 + (t * speed) * (size.height + 60);
      final x = x0 + math.sin(t * 8 + i) * 18;
      paint.color = _colors[i % _colors.length].withValues(alpha: (1 - t).clamp(0, 1));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 10 + i);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-4, -7, 8, 14), const Radius.circular(2)), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
