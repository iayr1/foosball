import 'package:flutter/material.dart';

class WinDialog extends StatelessWidget {
  final String winnerName;
  final VoidCallback onRestart;

  const WinDialog({
    super.key,
    required this.winnerName,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1B1D), Color(0xFF0D0E10)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0x66FF9F43),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66FF9F43),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🏆 ICON
              const Text(
                "🏆",
                style: TextStyle(fontSize: 48),
              ),

              const SizedBox(height: 12),

              /// 🎉 TITLE
              const Text(
                "Victory!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 10),

              /// 👤 WINNER TEXT
              Text(
                "$winnerName cleared the board first!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 22),

              /// 🔥 PLAY AGAIN BUTTON
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  onRestart();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF9F43),
                        Color(0xFFFF6A00),
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x88FF9F43),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Play Again",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}