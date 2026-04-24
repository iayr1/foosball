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
    return AlertDialog(
      title: const Text('Winner!'),
      content: Text('$winnerName cleared their side first.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRestart();
          },
          child: const Text('Play Again'),
        ),
      ],
    );
  }
}
