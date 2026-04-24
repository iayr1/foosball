import 'dart:ui';

import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';

class PauseDialog extends StatefulWidget {
  const PauseDialog({super.key, this.onResume, this.onRestart, this.onMainMenu});

  final VoidCallback? onResume;
  final VoidCallback? onRestart;
  final VoidCallback? onMainMenu;

  @override
  State<PauseDialog> createState() => _PauseDialogState();
}

class _PauseDialogState extends State<PauseDialog> {
  bool _soundOn = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xAA171717),
              border: Border.all(color: Colors.white24),
              boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 20, offset: Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('PAUSED', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                CustomButton(title: 'Resume', onTap: widget.onResume, subtitle: 'Back to game', icon: const Icon(Icons.play_arrow, color: Colors.white)),
                const SizedBox(height: 10),
                CustomButton(title: 'Restart', onTap: widget.onRestart, subtitle: 'Reset match', icon: const Icon(Icons.refresh, color: Colors.white)),
                const SizedBox(height: 10),
                CustomButton(title: 'Main Menu', onTap: widget.onMainMenu, subtitle: 'Exit game', icon: const Icon(Icons.home, color: Colors.white)),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  value: _soundOn,
                  activeColor: const Color(0xFF46C77B),
                  onChanged: (value) => setState(() => _soundOn = value),
                  title: const Text('Sound', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
