import 'package:flutter/material.dart';

enum Rarity { common, rare, epic, legendary }

extension RarityX on Rarity {
  String get label => switch (this) {
    Rarity.common => 'Common',
    Rarity.rare => 'Rare',
    Rarity.epic => 'Epic',
    Rarity.legendary => 'Legendary',
  };

  Color get color => switch (this) {
    Rarity.common => const Color(0xFF9AA6BF),
    Rarity.rare => const Color(0xFF3DD6F5),
    Rarity.epic => const Color(0xFFFFB547),
    Rarity.legendary => const Color(0xFFFF8FA6),
  };
}

enum StoreCategory { pucks, boards, bands, effects }

extension StoreCategoryX on StoreCategory {
  String get label => switch (this) {
    StoreCategory.pucks => 'Pucks',
    StoreCategory.boards => 'Boards',
    StoreCategory.bands => 'Bands',
    StoreCategory.effects => 'Effects',
  };
}

/// Anything the store can sell.
class StoreItem {
  final StoreCategory category;
  final String id;
  final String name;
  final Rarity rarity;
  final int price;
  final bool costsGems;

  const StoreItem(this.category, this.id, this.name, this.rarity, this.price, {this.costsGems = false});
}

class PuckSkin {
  final String id;
  final Color light;
  final Color base;
  final Color dark;
  const PuckSkin(this.id, this.light, this.base, this.dark);
}

class BoardSkin {
  final String id;
  final Color frame;
  final Color frameLight;
  final Color plankA;
  final Color plankB;
  final Color line;
  final bool ice;
  const BoardSkin(this.id, this.frame, this.frameLight, this.plankA, this.plankB, this.line, {this.ice = false});
}

class BandSkin {
  final String id;
  final Color color;
  final bool glow;
  const BandSkin(this.id, this.color, {this.glow = false});
}

enum TrailKind { none, spark, comet, quake }

class EffectSkin {
  final String id;
  final TrailKind kind;
  final Color color;
  const EffectSkin(this.id, this.kind, this.color);
}

class Catalog {
  Catalog._();

  static const items = <StoreItem>[
    StoreItem(StoreCategory.pucks, 'ember', 'Ember Classic', Rarity.common, 0),
    StoreItem(StoreCategory.pucks, 'tide', 'Tide', Rarity.common, 0),
    StoreItem(StoreCategory.pucks, 'jade', 'Jade', Rarity.rare, 350),
    StoreItem(StoreCategory.pucks, 'frost', 'Frostbite', Rarity.rare, 400),
    StoreItem(StoreCategory.pucks, 'copper', 'Copper', Rarity.rare, 450),
    StoreItem(StoreCategory.pucks, 'gold', 'Gilded', Rarity.epic, 900),
    StoreItem(StoreCategory.pucks, 'ruby', 'Ruby', Rarity.epic, 1000),
    StoreItem(StoreCategory.pucks, 'void', 'Void Glass', Rarity.legendary, 60, costsGems: true),
    StoreItem(StoreCategory.boards, 'walnut', 'Walnut', Rarity.common, 0),
    StoreItem(StoreCategory.boards, 'maple', 'Pale Maple', Rarity.rare, 500),
    StoreItem(StoreCategory.boards, 'midnight', 'Midnight', Rarity.epic, 1200),
    StoreItem(StoreCategory.boards, 'ice', 'Ice Rink', Rarity.legendary, 80, costsGems: true),
    StoreItem(StoreCategory.bands, 'rubber', 'Black Rubber', Rarity.common, 0),
    StoreItem(StoreCategory.bands, 'neon', 'Neon Cord', Rarity.rare, 350),
    StoreItem(StoreCategory.bands, 'chain', 'Brass Chain', Rarity.epic, 800),
    StoreItem(StoreCategory.bands, 'laser', 'Laser Line', Rarity.legendary, 50, costsGems: true),
    StoreItem(StoreCategory.effects, 'none', 'Clean', Rarity.common, 0),
    StoreItem(StoreCategory.effects, 'spark', 'Spark Trail', Rarity.rare, 450),
    StoreItem(StoreCategory.effects, 'comet', 'Comet Tail', Rarity.epic, 950),
    StoreItem(StoreCategory.effects, 'quake', 'Board Quake', Rarity.legendary, 70, costsGems: true),
  ];

  static const defaults = {
    StoreCategory.pucks: 'ember',
    StoreCategory.boards: 'walnut',
    StoreCategory.bands: 'rubber',
    StoreCategory.effects: 'none',
  };

  static List<StoreItem> inCategory(StoreCategory c) => items.where((i) => i.category == c).toList();

  static StoreItem item(String id) => items.firstWhere((i) => i.id == id);

  static const _pucks = {
    'ember': PuckSkin('ember', Color(0xFFFFD6B0), Color(0xFFFF8A3D), Color(0xFFA0400A)),
    'tide': PuckSkin('tide', Color(0xFFC9F6FF), Color(0xFF3DD6F5), Color(0xFF0F6E8C)),
    'jade': PuckSkin('jade', Color(0xFFE2FFD4), Color(0xFF6CD24A), Color(0xFF1E5A10)),
    'frost': PuckSkin('frost', Color(0xFFF2FDFF), Color(0xFF8FE3F5), Color(0xFF2C7F99)),
    'copper': PuckSkin('copper', Color(0xFFFFD9BE), Color(0xFFC8682C), Color(0xFF5A240A)),
    'gold': PuckSkin('gold', Color(0xFFFFF3C4), Color(0xFFFFB547), Color(0xFF8A5A0C)),
    'ruby': PuckSkin('ruby', Color(0xFFFFD1DA), Color(0xFFF2405E), Color(0xFF6A1022)),
    'void': PuckSkin('void', Color(0xFFE0D4FF), Color(0xFF7A55E8), Color(0xFF20104F)),
  };

  static PuckSkin puck(String id) => _pucks[id] ?? _pucks['ember']!;

  /// Colour the opponent plays with: Tide, unless the player already uses Tide.
  static PuckSkin opponentPuck(String playerPuckId) =>
      playerPuckId == 'tide' || playerPuckId == 'frost' ? _pucks['ember']! : _pucks['tide']!;

  static const _boards = {
    'walnut': BoardSkin('walnut', Color(0xFF5A3218), Color(0xFF7A4A28), Color(0xFFCC8E4F), Color(0xFFC2844A), Color(0xFF22262F)),
    'maple': BoardSkin('maple', Color(0xFFA9805A), Color(0xFFC49A70), Color(0xFFE9C89A), Color(0xFFDDBA8A), Color(0xFF22262F)),
    'midnight': BoardSkin('midnight', Color(0xFF15203A), Color(0xFF26355A), Color(0xFF2B3A55), Color(0xFF24324B), Color(0xFF3DD6F5)),
    'ice': BoardSkin('ice', Color(0xFF6FA9C2), Color(0xFF94C6DA), Color(0xFFF2FCFF), Color(0xFFDDF6FC), Color(0xFFFF5A7A), ice: true),
  };

  static BoardSkin board(String id) => _boards[id] ?? _boards['walnut']!;

  static const _bands = {
    'rubber': BandSkin('rubber', Color(0xFF22262F)),
    'neon': BandSkin('neon', Color(0xFF3DD6F5), glow: true),
    'chain': BandSkin('chain', Color(0xFFE2B04A)),
    'laser': BandSkin('laser', Color(0xFFFF5A7A), glow: true),
  };

  static BandSkin band(String id) => _bands[id] ?? _bands['rubber']!;

  static const _effects = {
    'none': EffectSkin('none', TrailKind.none, Color(0xFFFFFFFF)),
    'spark': EffectSkin('spark', TrailKind.spark, Color(0xFFFFB547)),
    'comet': EffectSkin('comet', TrailKind.comet, Color(0xFF3DD6F5)),
    'quake': EffectSkin('quake', TrailKind.quake, Color(0xFFFF5A7A)),
  };

  static EffectSkin effect(String id) => _effects[id] ?? _effects['none']!;

  /// Small swatch used in store tiles for boards/bands/effects.
  static Color swatch(StoreItem item) => switch (item.category) {
    StoreCategory.pucks => puck(item.id).base,
    StoreCategory.boards => board(item.id).plankA,
    StoreCategory.bands => band(item.id).color,
    StoreCategory.effects => item.id == 'none' ? const Color(0xFF4A5878) : effect(item.id).color,
  };
}
