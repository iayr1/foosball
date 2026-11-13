import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../data/profile.dart';
import '../theme/arena_theme.dart';
import '../widgets/board_art.dart';
import '../widgets/glossy.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  StoreCategory _tab = StoreCategory.pucks;

  void _act(StoreItem item) {
    final p = Profile.instance;
    if (p.isEquipped(item)) return;
    if (p.owns(item)) {
      p.equip(item);
      return;
    }
    if (!p.canAfford(item)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Arena.panel,
            behavior: SnackBarBehavior.floating,
            content: Text('Not enough ${item.costsGems ? 'gems' : 'coins'} yet — win matches to earn more.', style: Arena.body(14)),
          ),
        );
      return;
    }
    p.buy(item);
  }

  @override
  Widget build(BuildContext context) {
    final p = Profile.instance;
    return ListenableBuilder(
      listenable: p,
      builder: (context, _) {
        final items = Catalog.inCategory(_tab);
        return ArenaScaffold(
          glow: Arena.gold,
          child: Column(
            children: [
              PageHeader(
                title: 'Store',
                trailing: Row(
                  children: [
                    CurrencyPill(icon: const CoinIcon(size: 24), value: p.coins, semanticLabel: '${p.coins} coins'),
                    const SizedBox(width: 6),
                    CurrencyPill(icon: const GemIcon(size: 24), value: p.gems, semanticLabel: '${p.gems} gems'),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final pad = centeredPadding(c.maxWidth, maxContent: 900);
                    return CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: pad.copyWith(top: 16),
                          sliver: SliverToBoxAdapter(
                            child: MaxWidth(maxWidth: 560, child: _Preview(profile: p)),
                          ),
                        ),
                        SliverPadding(
                          padding: pad.copyWith(top: 14),
                          sliver: SliverToBoxAdapter(
                            child: MaxWidth(
                              maxWidth: 560,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(color: Arena.inset, borderRadius: BorderRadius.circular(18)),
                                child: Row(
                                  children: [
                                    for (final c in StoreCategory.values)
                                      Expanded(
                                        child: Semantics(
                                          selected: _tab == c,
                                          child: Pressable(
                                            onTap: () => setState(() => _tab = c),
                                            semanticLabel: c.label,
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 180),
                                              height: 40,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(13),
                                                gradient: _tab == c ? Gloss.orange.gradient : null,
                                                border: _tab == c ? Border.all(color: Arena.rim, width: 2) : null,
                                              ),
                                              child: Text(
                                                c.label,
                                                style: _tab == c
                                                    ? Arena.display(15, outline: Gloss.orange.outline, letterSpacing: 0.5)
                                                    : Arena.body(13, weight: FontWeight.w900, color: Arena.muted),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: pad.copyWith(top: 14, bottom: 24),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 210,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              mainAxisExtent: 240,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => _ItemTile(item: items[i], profile: p, onAct: () => _act(items[i])),
                              childCount: items.length,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final puck = Catalog.puck(profile.equippedId(StoreCategory.pucks));
    final effect = Catalog.item(profile.equippedId(StoreCategory.effects));
    return BevelPanel(
      padding: const EdgeInsets.all(12),
      borderColor: Arena.ember,
      child: Row(
        children: [
          MiniBoard(
            board: Catalog.board(profile.equippedId(StoreCategory.boards)),
            band: Catalog.band(profile.equippedId(StoreCategory.bands)),
            topPuck: Catalog.opponentPuck(puck.id),
            bottomPuck: puck,
            width: 78,
            height: 100,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR LOADOUT', style: Arena.label(11, color: Arena.gold)),
                const SizedBox(height: 4),
                for (final c in StoreCategory.values)
                  Text(
                    '${c.label}: ${Catalog.item(profile.equippedId(c)).name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Arena.body(
                      13,
                      weight: FontWeight.w800,
                      color: c == StoreCategory.effects && effect.id == 'none' ? Arena.muted : Arena.chalk,
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

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.profile, required this.onAct});

  final StoreItem item;
  final Profile profile;
  final VoidCallback onAct;

  @override
  Widget build(BuildContext context) {
    final owned = profile.owns(item);
    final equipped = profile.isEquipped(item);
    final afford = profile.canAfford(item);

    Widget preview;
    switch (item.category) {
      case StoreCategory.pucks:
        preview = PuckOrb(skin: Catalog.puck(item.id), size: 62);
      case StoreCategory.boards:
        preview = MiniBoard(board: Catalog.board(item.id), band: Catalog.band('rubber'), width: 56, height: 74);
      case StoreCategory.bands:
        final b = Catalog.band(item.id);
        preview = Container(
          width: 80,
          height: 8,
          decoration: BoxDecoration(
            color: b.color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [if (b.glow) BoxShadow(color: b.color.withValues(alpha: 0.7), blurRadius: 12)],
          ),
        );
      case StoreCategory.effects:
        final e = Catalog.effect(item.id);
        preview = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 4; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6.0 + i * 4,
                height: 6.0 + i * 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (item.id == 'none' ? Arena.dim : e.color).withValues(alpha: 0.25 + i * 0.25),
                ),
              ),
            PuckOrb(skin: Catalog.puck(profile.equippedId(StoreCategory.pucks)), size: 34),
          ],
        );
    }

    final String label;
    final Gloss gloss;
    if (equipped) {
      label = 'EQUIPPED';
      gloss = Gloss.locked;
    } else if (owned) {
      label = 'EQUIP';
      gloss = Gloss.blue;
    } else {
      label = formatNumber(item.price);
      gloss = afford ? (item.costsGems ? Gloss.purple : Gloss.orange) : Gloss.locked;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: Arena.panelGradient,
        border: Border.all(color: equipped ? Arena.ember : Arena.panelEdge, width: equipped ? 3 : 2),
        boxShadow: const [BoxShadow(color: Color(0xFF0A101C), offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Arena.night, borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: preview,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            style: Arena.body(14, weight: FontWeight.w900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            item.rarity.label,
            style: Arena.body(11, weight: FontWeight.w900, color: item.rarity.color),
          ),
          const SizedBox(height: 8),
          Pressable(
            onTap: equipped ? null : onAct,
            enabled: !equipped,
            semanticLabel: owned
                ? (equipped ? '${item.name} equipped' : 'Equip ${item.name}')
                : 'Buy ${item.name} for ${item.price} ${item.costsGems ? 'gems' : 'coins'}',
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: gloss.gradient,
                border: Border.all(color: equipped || (!owned && !afford) ? Arena.panelEdge : Arena.rim, width: 2.5),
                boxShadow: const [BoxShadow(color: Color(0xFF0A101C), offset: Offset(0, 3))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!owned) ...[item.costsGems ? const GemIcon(size: 18) : const CoinIcon(size: 18), const SizedBox(width: 5)],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: equipped || (!owned && !afford)
                            ? Arena.body(13, weight: FontWeight.w900, color: Arena.muted)
                            : Arena.display(15, outline: gloss.outline, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
