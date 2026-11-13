import 'package:flutter/material.dart';

import '../audio/sfx_service.dart';
import '../data/profile.dart';
import '../game/physics.dart';
import '../theme/arena_theme.dart';
import '../widgets/glossy.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 520),
    builder: (_) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    final p = Profile.instance;
    return ListenableBuilder(
      listenable: p,
      builder: (context, _) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: Arena.metalGradient),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: Arena.panelGradient),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Settings', style: Arena.display(28)),
                  const SizedBox(height: 8),
                  SettingsToggles(profile: p),
                  const SizedBox(height: 14),
                  GlossyButton(label: 'DONE', gloss: Gloss.green, height: 56, fontSize: 24, onTap: () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sound / vibration / aim-guide switches, shared by the sheet and the pause menu.
class SettingsToggles extends StatelessWidget {
  const SettingsToggles({super.key, required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlossSwitch(
          label: 'Sound effects',
          value: profile.sound,
          onChanged: (v) {
            profile.setSound(v);
            SfxService.instance.setEnabled(v);
          },
        ),
        GlossSwitch(
          label: 'Vibration',
          value: profile.haptics,
          onChanged: (v) {
            profile.setHaptics(v);
            PhysicsEngine.hapticsEnabled = v;
          },
        ),
        GlossSwitch(label: 'Aim guide line', value: profile.aimGuide, onChanged: profile.setAimGuide),
      ],
    );
  }
}
