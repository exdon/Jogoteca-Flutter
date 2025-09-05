import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jogoteca/shared/shared_widgets.dart';

class GamePopGuard extends StatelessWidget {
  final Widget child;

  const GamePopGuard({
    super.key,
    required this.child
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        SharedWidgets.showExitConfirmationDialog(context: context);
      },
      child: child,
    );
  }
}
