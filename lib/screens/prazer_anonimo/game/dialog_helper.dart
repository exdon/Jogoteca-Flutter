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
        title: const Text('Directs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Color(0xFF0d2412),
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
                    color: !message['lida'] ? Color(0xFF214F1B) : null,
                    child: ListTile(
                      title: const Text('De: **********', style: TextStyle(fontWeight: FontWeight.bold),),
                      subtitle: Text(message['lida'] ? 'Lida' : 'Não lida', textAlign: TextAlign.end,),
                      subtitleTextStyle: TextStyle(color: !message['lida'] ? Colors.white : Colors.black),
                      onTap: () {
                        if (!message['lida']) {
                          onReadMessage(message, playerId, setStateDialog);
                        } else {
                          onReadAgainMessage(message);
                        }
                      },
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
            child: const Text('Fechar', style: TextStyle(color: Colors.white),),
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
        contentPadding: const EdgeInsets.only(top: 10, left: 24, right: 24, bottom: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mensagem',
                  style: TextStyle(
                    color: Color(0xFF214F1B),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (!message['lida']) {
                      playersBloc.add(MarkMessageAsRead(partidaId, playerId, message['id']));

                      final index = directMessages.indexWhere((m) => m['id'] == message['id']);
                      if (index != -1) {
                        directMessages[index]['lida'] = true;
                      }
                      onUpdateMainState();

                      if (setStateDialog != null) {
                        setStateDialog(() {});
                      }
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(message['mensagem'], style: TextStyle(fontSize: 16)),
          ],
        ),
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
        contentPadding: const EdgeInsets.only(top: 10, left: 24, right: 24, bottom: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mensagem',
                  style: TextStyle(
                    color: Color(0xFF214F1B),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF214F1B),),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(message['mensagem'], style: TextStyle(fontSize: 16),),
          ],
        ),
      ),
    );
  }
}