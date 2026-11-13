import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../controllers/ai_controller.dart';
import '../controllers/game_controller.dart';
import '../data/catalog.dart';
import '../data/match_config.dart';
import '../data/profile.dart';
import '../game/sling_puck_game.dart';
import '../models/player.dart';
import '../theme/arena_theme.dart';
import '../widgets/glossy.dart';
import 'result_screen.dart';
import 'settings_sheet.dart';

void startMatch(BuildContext context, MatchConfig config, {bool replace = false}) {
  final route = MaterialPageRoute<void>(builder: (_) => MatchScreen(config: config));
  if (replace) {
    Navigator.of(context).pushReplacement(route);
  } else {
    Navigator.of(context).push(route);
  }
}

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key, required this.config});
  final MatchConfig config;

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late final GameController _controller;
  late final SlingPuckGame _game;
  late final PuckSkin _playerSkin;
  late final PuckSkin _opponentSkin;

  final _profile = Profile.instance;
  final _power = ValueNotifier<double?>(null);
  final _gameKey = GlobalKey();

  Timer? _ticker;
  final Stopwatch _clock = Stopwatch();
  bool _paused = false;
  bool _finished = false;
  bool _showIntro = false;
  int _lastComboSerial = 0;
  int _comboValue = 0;
  int _comboKey = 0;

  MatchConfig get config => widget.config;

  @override
  void initState() {
    super.initState();
    _playerSkin = Catalog.puck(_profile.equippedId(StoreCategory.pucks));
    _opponentSkin = Catalog.opponentPuck(_playerSkin.id);

    _controller = GameController(
      mode: config.engineMode,
      topPlayer: Player(id: 'top', name: config.opponentName, puckColor: _opponentSkin.base, startsOnTop: true),
      bottomPlayer: Player(id: 'bottom', name: 'You', puckColor: _playerSkin.base, startsOnTop: false),
      pucksPerPlayer: config.pucksPerSide,
      solo: config.isSolo,
    )..addListener(_onGame);

    _game = SlingPuckGame(
      controller: _controller,
      aiController: AiController(difficulty: config.difficulty),
      skins: MatchSkins(
        bottomPuck: _playerSkin,
        topPuck: _opponentSkin,
        board: Catalog.board(_profile.equippedId(StoreCategory.boards)),
        band: Catalog.band(_profile.equippedId(StoreCategory.bands)),
        effect: Catalog.effect(_profile.equippedId(StoreCategory.effects)),
      ),
      showAimGuide: () => _profile.aimGuide,
      onAim: (v) => _power.value = v,
    );

    _clock.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());

    if (!_profile.seenIntro || config.style == PlayStyle.practice) {
      _showIntro = true;
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showIntro = false);
      });
      _profile.markIntroSeen();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.removeListener(_onGame);
    _controller.dispose();
    _power.dispose();
    super.dispose();
  }

  int get _seconds => _clock.elapsed.inSeconds;

  int? get _remaining => config.timeLimit == null ? null : (config.timeLimit! - _seconds).clamp(0, config.timeLimit!);

  void _tick() {
    if (!mounted || _finished) return;
    if (_remaining == 0) _controller.forfeitBottom();
    setState(() {});
  }

  void _onGame() {
    if (!mounted) return;
    if (_controller.comboSerial != _lastComboSerial) {
      _lastComboSerial = _controller.comboSerial;
      _comboValue = _controller.lastCombo;
      final key = ++_comboKey;
      tapFeedback();
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted && _comboKey == key) setState(() => _comboValue = 0);
      });
    }
    if (_controller.state.hasWinner && !_finished) {
      _finished = true;
      _clock.stop();
      Future.delayed(const Duration(milliseconds: 900), _finish);
    }
    setState(() {});
  }

  void _finish() {
    if (!mounted) return;
    final won = _controller.state.winnerId == _controller.bottomPlayer.id;
    final summary = _profile.recordMatch(
      MatchResult(
        config: config,
        playerWon: won,
        seconds: _seconds,
        opponentCleared: _controller.state.blackOnOpponentSide,
        bestCombo: _controller.bestComboBottom,
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          config: config,
          playerWon: won,
          summary: summary,
          seconds: _seconds,
          playerSent: _controller.state.whiteOnOpponentSide,
          opponentSent: _controller.state.blackOnOpponentSide,
        ),
      ),
    );
  }

  void _setPaused(bool v) {
    if (_finished) return;
    setState(() => _paused = v);
    _game.setPaused(v);
    v ? _clock.stop() : _clock.start();
  }

  void _restart() {
    _game.restart();
    _clock
      ..reset()
      ..start();
    _finished = false;
    _setPaused(false);
  }

  String _turnText() {
    final t = _controller.turn;
    if (_controller.state.hasWinner) return '';
    return switch (t) {
      GameTurn.human => config.style == PlayStyle.passAndPlay ? 'PLAYER 1 · YOUR TURN' : 'YOUR TURN',
      GameTurn.player2 => 'PLAYER 2 · YOUR TURN',
      GameTurn.ai => '${config.difficulty.botName.toUpperCase()} IS AIMING…',
      GameTurn.waiting => '',
      GameTurn.gameOver => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = _controller.state;
    final n = config.pucksPerSide;
    final playerLeft = n - s.whiteOnOpponentSide;
    final opponentLeft = n - s.blackOnOpponentSide;
    final rem = _remaining;
    final clock = rem ?? _seconds;
    final clockText = '${clock ~/ 60}:${(clock % 60).toString().padLeft(2, '0')}';
    final urgent = rem != null && rem <= 10;
    final turn = _turnText();
    final topTurn = _controller.turn == GameTurn.player2 || _controller.turn == GameTurn.ai;

    final opponentCard = _SideCard(
      name: config.opponentName,
      skin: _opponentSkin,
      left: config.isSolo ? null : opponentLeft,
      total: n,
      gloss: Gloss.blue,
      icon: config.style == PlayStyle.passAndPlay ? Icons.person_rounded : Icons.smart_toy_rounded,
      active: topTurn,
    );
    final playerCard = _SideCard(
      name: config.style == PlayStyle.passAndPlay ? 'Player 1' : 'You',
      skin: _playerSkin,
      left: playerLeft,
      total: n,
      gloss: Gloss.orange,
      icon: Icons.person_rounded,
      active: !topTurn && _controller.turn == GameTurn.human,
    );
    final clockBox = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: urgent ? Gloss.red.gradient : Arena.panelGradient,
        border: Border.all(color: urgent ? Arena.rim : Arena.panelEdge, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(clockText, style: Arena.display(22, outline: urgent ? Gloss.red.outline : null)),
          Text(rem != null ? 'LEFT' : 'TIME', style: Arena.label(9, color: urgent ? Colors.white : Arena.muted)),
        ],
      ),
    );
    final pauseButton = RoundGlossButton(icon: Icons.pause_rounded, semanticLabel: 'Pause', onTap: () => _setPaused(true));
    final powerMeter = ValueListenableBuilder<double?>(
      valueListenable: _power,
      builder: (context, v, _) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(v == null ? 'POWER' : 'POWER ${(v * 100).round()}%', style: Arena.label(10, color: Arena.gold)),
          const SizedBox(height: 4),
          MetalBar(value: v ?? 0, gloss: Gloss.orange, height: 20),
        ],
      ),
    );
    final board = Stack(
      children: [
        Positioned.fill(
          child: GameWidget(key: _gameKey, game: _game),
        ),
        if (turn.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            top: topTurn ? 10 : null,
            bottom: topTurn ? null : 10,
            child: IgnorePointer(
              child: Center(
                child: _TurnBanner(key: ValueKey(turn), text: turn, top: topTurn),
              ),
            ),
          ),
        if (_comboValue >= 2)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: FittedBox(
                  child: _ComboPop(key: ValueKey(_comboKey), count: _comboValue),
                ),
              ),
            ),
          ),
        if (_showIntro)
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: const Alignment(0, 0.25),
                child: _IntroTip(solo: config.isSolo),
              ),
            ),
          ),
      ],
    );

    final landscape = context.isLandscape;

    final Widget layout;
    if (landscape) {
      // HUD in two side panels so the (portrait) board gets the full height.
      final side = (context.screen.width * 0.26).clamp(170.0, 260.0);
      layout = Row(
        children: [
          SizedBox(
            width: side,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
              child: Column(
                children: [
                  opponentCard,
                  const Spacer(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [clockBox, pauseButton]),
                ],
              ),
            ),
          ),
          Expanded(child: board),
          SizedBox(
            width: side,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 12, 8),
              child: Column(children: [const Spacer(), powerMeter, const SizedBox(height: 10), playerCard]),
            ),
          ),
        ],
      );
    } else {
      layout = Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
            child: Row(
              children: [
                Expanded(child: opponentCard),
                const SizedBox(width: 8),
                clockBox,
                const SizedBox(width: 8),
                pauseButton,
              ],
            ),
          ),
          Expanded(child: board),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            child: Row(
              children: [
                Expanded(child: playerCard),
                const SizedBox(width: 10),
                SizedBox(width: (context.screen.width * 0.34).clamp(100.0, 180.0), child: powerMeter),
              ],
            ),
          ),
        ],
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _setPaused(true);
      },
      child: Scaffold(
        backgroundColor: Arena.deepNight,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: layout),
              if (_paused) _PauseOverlay(onResume: () => _setPaused(false), onRestart: _restart, title: config.title),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideCard extends StatelessWidget {
  const _SideCard({
    required this.name,
    required this.skin,
    required this.left,
    required this.total,
    required this.gloss,
    required this.icon,
    required this.active,
  });

  final String name;
  final PuckSkin skin;
  final int? left;
  final int total;
  final Gloss gloss;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: Arena.panelGradient,
        border: Border.all(color: active ? skin.base : Arena.panelEdge, width: 2),
        boxShadow: [if (active) BoxShadow(color: skin.base.withValues(alpha: 0.3), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: gloss.gradient,
              border: Border.all(color: Arena.rim, width: 2),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: Arena.body(13, weight: FontWeight.w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                if (left == null)
                  Text('Clear every puck', style: Arena.body(11, color: Arena.muted))
                else
                  Semantics(
                    label: '$left pucks left',
                    child: Wrap(
                      spacing: 3,
                      runSpacing: 3,
                      children: [
                        for (var i = 0; i < total; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: i < left! ? skin.base : Arena.track),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TurnBanner extends StatelessWidget {
  const _TurnBanner({super.key, required this.text, required this.top});
  final String text;
  final bool top;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0, 1),
        child: Transform.scale(scale: 0.8 + v * 0.2, child: child),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Arena.deepNight.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: top ? Arena.tide : Arena.ember, width: 2),
        ),
        child: Text(text, style: Arena.body(12, weight: FontWeight.w900, letterSpacing: 1.5)),
      ),
    );
  }
}

class _ComboPop extends StatelessWidget {
  const _ComboPop({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final label = switch (count) {
      2 => 'DOUBLE!',
      3 => 'TRIPLE!',
      _ => 'MEGA x$count!',
    };
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, v, child) => Transform.rotate(
        angle: -0.1,
        child: Transform.scale(scale: v, child: child),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: Gloss.gold.gradient,
          border: Border.all(color: Arena.rim, width: 4),
          boxShadow: const [
            BoxShadow(color: Arena.dropEdge, offset: Offset(0, 5)),
            BoxShadow(color: Color(0x88000000), blurRadius: 20),
          ],
        ),
        child: Text(
          label,
          style: Arena.display(40, color: Colors.white, outline: Gloss.gold.outline),
        ),
      ),
    );
  }
}

class _IntroTip extends StatelessWidget {
  const _IntroTip({required this.solo});
  final bool solo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Arena.deepNight.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Arena.gold, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.touch_app_rounded, color: Arena.gold, size: 30),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              solo
                  ? 'Pull a glowing puck back and let go. Send every puck through the gap!'
                  : 'Pull a glowing puck back and let go. First to clear all pucks wins!',
              style: Arena.body(13, weight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({required this.onResume, required this.onRestart, required this.title});

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final String title;

  @override
  Widget build(BuildContext context) {
    final p = Profile.instance;
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.7),
        child: FitCard(
          maxWidth: 340,
          child: ListenableBuilder(
            listenable: p,
            builder: (context, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'PAUSED',
                  textAlign: TextAlign.center,
                  style: Arena.display(36, color: Arena.gold, outline: const Color(0xFF8A4A0C)),
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Arena.body(13, color: Arena.muted),
                ),
                const SizedBox(height: 8),
                SettingsToggles(profile: p),
                const SizedBox(height: 12),
                GlossyButton(label: 'RESUME', gloss: Gloss.green, height: 58, fontSize: 24, onTap: onResume),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GlossyButton(label: 'RESTART', gloss: Gloss.blue, height: 50, fontSize: 18, onTap: onRestart),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GlossyButton(
                        label: 'QUIT',
                        gloss: Gloss.red,
                        height: 50,
                        fontSize: 18,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
