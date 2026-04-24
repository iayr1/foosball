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
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xB219120A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _badge(
                '${controller.topPlayer.name}: ${state.blackOnOpponentSide}/${GameController.totalPucksPerPlayer}',
                controller.topPlayer.puckColor,
              ),
              Text(
                'Turn: ${controller.turnLabel}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _badge(
                '${controller.bottomPlayer.name}: ${state.whiteOnOpponentSide}/${GameController.totalPucksPerPlayer}',
                controller.bottomPlayer.puckColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}
