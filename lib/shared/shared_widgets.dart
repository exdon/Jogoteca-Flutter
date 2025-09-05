import 'package:flutter/material.dart';

class SharedWidgets {
  static Future<bool> showExitConfirmationDialog({required BuildContext context}) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Encerrar jogo?'),
        content: const Text('Para encerrar o jogo, clique no icone de sair no canto direito superior do app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }
}
