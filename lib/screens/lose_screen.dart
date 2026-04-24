import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';

class LoseScreen extends StatelessWidget {
  const LoseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1D0A0A), Color(0xFF420E0E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sentiment_dissatisfied, size: 80, color: Color(0xFFFF6C6C)),
                const SizedBox(height: 14),
                const Text('YOU LOSE!', style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                const Text('2 - 5', style: TextStyle(color: Colors.white70, fontSize: 34, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('+20 coins', style: TextStyle(color: Color(0xFFFFB366), fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 26),
                CustomButton(
                  title: 'Play Again',
                  subtitle: 'Try one more round',
                  gradient: const LinearGradient(colors: [Color(0xFFE25A5A), Color(0xFFB13030)]),
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 10),
                CustomButton(title: 'Main Menu', subtitle: 'Back to home', onTap: () => Navigator.of(context).popUntil((route) => route.isFirst)),
                const SizedBox(height: 10),
                CustomButton(title: 'Share', subtitle: 'Share your score', onTap: () {}, icon: const Icon(Icons.share, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
