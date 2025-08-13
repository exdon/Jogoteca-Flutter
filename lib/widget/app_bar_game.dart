import 'package:flutter/material.dart';

import '../screens/home_screen.dart';

class AppBarGame extends StatelessWidget implements PreferredSizeWidget {

  const AppBarGame({super.key,});

  Future<void> _encerrarPartida(BuildContext context) async {
    final confirmar = await _mostrarDialogoConfirmacao(context);
    if (confirmar == true && context.mounted) {

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
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
