import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/players/players_bloc.dart';
import 'package:jogoteca/blocs/players/players_event.dart';

class DialogHelper {
  static void showPinDialog({
    required BuildContext context,
    required TextEditingController pinController,
    required String playerId,
    required String correctPin,
    required List<Map<String, dynamic>> questions,
    required List<Map<String, dynamic>> players,
    required bool isProcessing,
    required Function(BuildContext, String, String, List<Map<String, dynamic>>, List<Map<String, dynamic>>) onCheckPin,
  }) {
    pinController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Validar PIN"),
          content: TextField(
            controller: pinController,
            enabled: !isProcessing,
            decoration: const InputDecoration(
              labelText: "Digite o PIN",
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightGreen),
              ),
              counterStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            obscureText: true,
            keyboardType: TextInputType.number,
            cursorColor: Colors.green,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (!isProcessing) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: isProcessing
                  ? null
                  : () => onCheckPin(dialogContext, playerId, correctPin, questions, players),
              child: isProcessing
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text(
                "Confirmar",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showDirectMessagesDialog({
    required BuildContext context,
    required List<Map<String, dynamic>> directMessages,
    required String playerId,
    required Function(Map<String, dynamic>, String, void Function(void Function())?) onReadMessage,
    required Function(Map<String, dynamic>) onReadAgainMessage,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Directs'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return ListView.builder(
                itemCount: directMessages.length,
                itemBuilder: (context, index) {
                  final message = directMessages[index];
                  return Card(
                    child: ListTile(
                      title: const Text('De: **********'),
                      subtitle: Text(message['lida'] ? '(lida)' : '(não lida)'),
                      trailing: !message['lida']
                          ? TextButton(
                        onPressed: () {
                          onReadMessage(message, playerId, setStateDialog);
                        },
                        child: const Text('Ler'),
                      )
                          : TextButton(
                        onPressed: () {
                          onReadAgainMessage(message);
                        },
                        child: const Text('Reler'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  static void showReadMessageDialog({
    required BuildContext context,
    required Map<String, dynamic> message,
    required String playerId,
    required String partidaId,
    required List<Map<String, dynamic>> directMessages,
    required void Function(void Function())? setStateDialog,
    required VoidCallback onUpdateMainState,
  }) {
    final playersBloc = context.read<PlayersBloc>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mensagem'),
        content: Text(message['mensagem']),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (!message['lida']) {
                // Atualiza no backend
                playersBloc.add(MarkMessageAsRead(partidaId, playerId, message['id']));

                // Atualiza na lista principal
                final index = directMessages.indexWhere((m) => m['id'] == message['id']);
                if (index != -1) {
                  directMessages[index]['lida'] = true;
                }
                onUpdateMainState();

                // Atualiza também no modal da lista
                if (setStateDialog != null) {
                  setStateDialog(() {});
                }
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  static void showReadMessageAgainDialog({
    required BuildContext context,
    required Map<String, dynamic> message,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mensagem'),
        content: Text(message['mensagem']),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}