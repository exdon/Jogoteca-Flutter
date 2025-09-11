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
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Deseja Encerrar o jogo?', style: TextStyle(color: Colors.white),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Atenção!',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8,),
            const Text(
              'Todos os dados serão apagados e as configurações resetadas.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 8,),
            const Text(
              'Deseja continuar?',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
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
