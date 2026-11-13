import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../data/profile.dart';
import '../theme/arena_theme.dart';
import 'glossy.dart';

/// Opens one ready chest with a shake-then-burst animation and shows the loot.
Future<void> showChestDialog(BuildContext context) async {
  if (Profile.instance.chestsReady <= 0) return;
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, _, _) => const _ChestDialog(),
    transitionBuilder: (_, a, _, child) => ScaleTransition(
      scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
      child: child,
    ),
  );
}

class _ChestDialog extends StatefulWidget {
  const _ChestDialog();

  @override
  State<_ChestDialog> createState() => _ChestDialogState();
}

class _ChestDialogState extends State<_ChestDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  ChestReward? _reward;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    tapFeedback();
    await _c.forward();
    setState(() => _reward = Profile.instance.openChest());
  }

  @override
  Widget build(BuildContext context) {
    final r = _reward;
    return Material(
      type: MaterialType.transparency,
      child: FitCard(
        maxWidth: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              r == null ? 'CHEST' : 'YOU GOT',
              style: Arena.display(34, color: Arena.gold, outline: const Color(0xFF8A4A0C)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 130,
              child: r == null
                  ? AnimatedBuilder(
                      animation: _c,
                      builder: (context, child) {
                        final shake = _c.value < 0.8 ? (0.5 - (_c.value * 12) % 1).abs() * 0.3 * (_c.value * 1.4) : 0.0;
                        final grow = 1.0 + (_c.value > 0.8 ? (_c.value - 0.8) * 2.5 : 0.0);
                        return Transform.rotate(
                          angle: shake - 0.075,
                          child: Transform.scale(scale: grow, child: child),
                        );
                      },
                      child: const ChestIcon(size: 120),
                    )
                  : _Loot(reward: r),
            ),
            const SizedBox(height: 22),
            if (r == null)
              GlossyButton(label: 'OPEN', gloss: Gloss.green, onTap: _c.isAnimating ? null : _open)
            else
              GlossyButton(label: 'COLLECT', onTap: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}

class _Loot extends StatelessWidget {
  const _Loot({required this.reward});
  final ChestReward reward;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      _tile(const CoinIcon(size: 44), '+${reward.coins}'),
      if (reward.gems > 0) _tile(const GemIcon(size: 44), '+${reward.gems}'),
      if (reward.item != null)
        _tile(
          reward.item!.category == StoreCategory.pucks
              ? PuckOrb(skin: Catalog.puck(reward.item!.id), size: 48)
              : Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: Catalog.swatch(reward.item!), borderRadius: BorderRadius.circular(10)),
                ),
          reward.item!.name,
        ),
    ];
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: tiles),
    );
  }

  Widget _tile(Widget icon, String label) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(height: 56, child: Center(child: icon)),
      const SizedBox(height: 8),
      Text(
        label,
        style: Arena.body(14, weight: FontWeight.w900),
        textAlign: TextAlign.center,
      ),
    ],
  );
}
