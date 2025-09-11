import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/prazer_anonimo/players/players_bloc_pa.dart';
import 'package:jogoteca/blocs/prazer_anonimo/players/players_event_pa.dart';

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
          backgroundColor: const Color(0xFF0d1a0f),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.green.withOpacity(0.5), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text(
            "// Validar PIN",
            style: TextStyle(color: Colors.green, fontFamily: 'monospace'),
          ),
          content: TextField(
            controller: pinController,
            enabled: !isProcessing,
            decoration: InputDecoration(
              labelText: "PIN_DA_RODADA",
              labelStyle: TextStyle(color: Colors.green.withOpacity(0.7), fontFamily: 'monospace'),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.cyanAccent),
              ),
              counterStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            obscureText: true,
            keyboardType: TextInputType.number,
            cursorColor: Colors.cyanAccent,
            style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (!isProcessing) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text(
                "cancelar",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
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
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent)),
                    )
                  : const Text(
                      "confirmar",
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
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
        title: const Text(
          '// Directs',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        ),
        backgroundColor: const Color(0xFF0d1a0f),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.green.withOpacity(0.5), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              if (directMessages.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma mensagem recebida.',
                    style: TextStyle(color: Colors.white70, fontFamily: 'monospace'),
                  ),
                );
              }
              return ListView.builder(
                itemCount: directMessages.length,
                itemBuilder: (context, index) {
                  final message = directMessages[index];
                  final isUnread = !message['lida'];
                  return Card(
                    color: isUnread ? const Color(0xFF1a3b20) : Colors.black.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: isUnread ? Colors.green : Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListTile(
                      leading: Icon(isUnread ? Icons.mark_email_unread_outlined : Icons.mark_email_read_outlined, color: isUnread ? Colors.greenAccent : Colors.grey),
                      title: const Text(
                        'De: **********',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'monospace'),
                      ),
                      subtitle: Text(
                        isUnread ? 'Nova Mensagem' : 'Lida',
                        textAlign: TextAlign.end,
                        style: TextStyle(color: isUnread ? Colors.greenAccent : Colors.grey, fontFamily: 'monospace'),
                      ),
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
            child: const Text('fechar', style: TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace')),
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
    final playersBloc = context.read<PlayersBlocPA>();

    showDialog(
      context: context,
      barrierDismissible: false, // Impede fechar ao clicar fora
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0d1a0f),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.green.withOpacity(0.5), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.all(0),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header fixo
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '// Mensagem',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: 'monospace',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () {
                        if (!message['lida']) {
                          playersBloc.add(MarkMessageAsReadPA(partidaId, playerId, message['id']));

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
              ),
              const Divider(color: Colors.green),
              // Conteúdo da mensagem com scroll
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                  child: Text(
                    message['mensagem'],
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
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
        backgroundColor: const Color(0xFF0d1a0f),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.all(0),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header fixo
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '// Mensagem',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: 'monospace',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey),
              // Conteúdo da mensagem com scroll
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                  child: Text(
                    message['mensagem'],
                    style: const TextStyle(fontSize: 16, color: Colors.white70, fontFamily: 'monospace'),
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