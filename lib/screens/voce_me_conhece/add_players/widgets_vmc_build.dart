import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WidgetsVMCBuild {

  static Widget buildAddButton({
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const FaIcon(FontAwesomeIcons.userPlus, color: Colors.black),
      label: const Text(
        'Adicionar jogador',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }

  static Widget buildPlayerFields({
    required TextEditingController nomeController,
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: nomeController,
            // enabled: !isNavigating,
            decoration: InputDecoration(
              labelText: 'Nome do jogador',
              labelStyle: const TextStyle(color: Colors.white),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightGreen),
              ),
              suffixIcon: IconButton(
                onPressed: onCancel,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.green,
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white70,
              foregroundColor: Colors.black,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_kabaddi, size: 24),
                SizedBox(width: 15),
                Text('Salvar Jogador', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildPlayersList({required List<Map<String, dynamic>> players}) {
    if (players.isEmpty) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Nenhum jogador cadastrado',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Text(
                'Adicione jogadores para iniciar o jogo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      );
    }

    // Lista de jogadores
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: players.length + 1, // +1 para o título
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Jogadores:',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          );
        }
        final player = players[index - 1];
        return ListTile(
          leading: const Icon(FontAwesomeIcons.userNinja, color: Colors.white),
          title: Text(
            player['nome'],
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  static OverlayEntry createInfoOverlay({
    required BuildContext context,
    required VoidCallback onClose,
  }) {
    final screenSize = MediaQuery.of(context).size;

    return OverlayEntry(
      builder: (context) => Positioned(
        top: screenSize.height / 2 - 100,
        left: screenSize.width / 2 - 125,
        child: Material(
          elevation: 8,
          color: Colors.transparent,
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Por que adicionar jogadores?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Isso permite personalizar a experiência e registrar respostas individuais.',
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onClose,
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildStartGameButton({required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white70,
          foregroundColor: Colors.black
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.dice),
            SizedBox(width: 15),
            Text('Iniciar Jogo', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

}
