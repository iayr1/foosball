import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';

class WinScreen extends StatelessWidget {
  const WinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B0F18), Color(0xFF162745)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.workspace_premium, size: 80, color: Color(0xFFFFD84D)),
                const SizedBox(height: 14),
                const Text('YOU WIN!', style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('5 - 2', style: TextStyle(color: Colors.white70, fontSize: 34, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('+50 coins', style: TextStyle(color: Color(0xFF56D987), fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 26),
                CustomButton(
                  title: 'Play Again',
                  subtitle: 'Start new match',
                  gradient: const LinearGradient(colors: [Color(0xFF4CD97D), Color(0xFF2D9E58)]),
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 10),
                CustomButton(title: 'Main Menu', subtitle: 'Back to home', onTap: () => Navigator.of(context).popUntil((route) => route.isFirst)),
                const SizedBox(height: 10),
                CustomButton(title: 'Share', subtitle: 'Share your victory', onTap: () {}, icon: const Icon(Icons.share, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
