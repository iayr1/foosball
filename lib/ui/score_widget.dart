import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';

class ScoreWidget extends StatelessWidget {
  final GameController controller;

  const ScoreWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final state = controller.state;

        final topText =
            '${controller.topPlayer.name}: ${state.blackOnOpponentSide}/${GameController.totalPucksPerPlayer}';

        final bottomText =
            '${controller.bottomPlayer.name}: ${state.whiteOnOpponentSide}/${GameController.totalPucksPerPlayer}';

        final isTopTurn = controller.turnLabel
            .toLowerCase()
            .contains(controller.topPlayer.name.toLowerCase());

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1B1D), Color(0xFF0D0E10)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),

          child: Row(
            children: [
              /// 🔝 TOP PLAYER
              Flexible(
                child: _badge(
                  text: topText,
                  color: controller.topPlayer.puckColor,
                  isActive: isTopTurn,
                  alignRight: false,
                ),
              ),

              /// 🎯 TURN INDICATOR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.4),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Text(
                    controller.turnLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              /// 🔻 BOTTOM PLAYER
              Flexible(
                child: _badge(
                  text: bottomText,
                  color: controller.bottomPlayer.puckColor,
                  isActive: !isTopTurn,
                  alignRight: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _badge({
    required String text,
    required Color color,
    required bool isActive,
    required bool alignRight,
  }) {
    return Row(
      mainAxisAlignment:
          alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withOpacity(0.18),
              border: Border.all(
                color: isActive
                    ? color.withOpacity(0.9)
                    : color.withOpacity(0.4),
                width: isActive ? 1.5 : 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 10,
                      )
                    ]
                  : [],
            ),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // 🔥 overflow fix
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    isActive ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}