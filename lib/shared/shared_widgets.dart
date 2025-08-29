import 'package:flutter/material.dart';
import 'package:jogoteca/screens/home/home_screen.dart';
import 'package:jogoteca/shared/service/shared_service.dart';

class SharedWidgets {
  static Future<bool> showExitConfirmationDialog({
    required BuildContext context,
    required String partidaId,
    required String gameId,
    required String database,
  }) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Encerrar partida?'),
        content: const Text('Deseja encerrar e voltar para a tela inicial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await SharedService(
                gameId: gameId,
                database: database,
                partidaId: partidaId,
              ).setPartidaAtiva(false);

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }
}
