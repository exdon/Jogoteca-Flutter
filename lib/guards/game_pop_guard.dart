import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jogoteca/shared/shared_widgets.dart';

class GamePopGuard extends StatelessWidget {
  final Widget child;
  final String partidaId;
  final String gameId;
  final String database;

  const GamePopGuard({
    super.key,
    required this.child,
    required this.partidaId,
    required this.gameId,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        SharedWidgets.showExitConfirmationDialog(
          context: context,
          partidaId: partidaId,
          gameId: gameId,
          database: database,
        );
      },
      child: child,
    );
  }
}
