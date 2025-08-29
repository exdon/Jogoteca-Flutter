import 'package:flutter/material.dart';
import 'package:jogoteca/screens/home/home_screen.dart';
import 'package:jogoteca/shared/service/shared_service.dart';

class AppBarGame extends StatelessWidget implements PreferredSizeWidget {
  final bool disablePartida;
  final bool deletePartida;
  final String partidaId;
  final String gameId;
  final String database;

  const AppBarGame({
    super.key,
    required this.disablePartida,
    required this.partidaId,
    required this.deletePartida,
    required this.gameId,
    required this.database
});

  Future<void> _encerrarPartida(BuildContext context) async {
    final confirmar = await _mostrarDialogoConfirmacao(context);
    if (confirmar == true && context.mounted) {

      if (partidaId.isNotEmpty) {
        if (deletePartida) {
          try {
            await SharedService(gameId: gameId, database: database, partidaId: partidaId)
                .deletePartida();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao deletar partida: $e')),
              );
            }
          }
        } else if (disablePartida) {
          try {
            await SharedService(gameId: gameId, database: database, partidaId: partidaId)
                .setPartidaAtiva(false);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao desativar partida: $e')),
              );
            }
          }
        }
      }

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomeScreen()),
              (route) => false,
        );
      }
    }
  }

  Future<bool?> _mostrarDialogoConfirmacao(BuildContext context) {
    return showDialog<bool>(
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
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.exit_to_app, color: Colors.white),
          onPressed: () => _encerrarPartida(context),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
