import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddPlayersWidgets {
  static Widget buildAddButton({
    required bool isNavigating,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: isNavigating ? null : onPressed,
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
    required TextEditingController pinController,
    required bool isNavigating,
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) {
    return Column(
      children: [
        TextField(
          controller: nomeController,
          enabled: !isNavigating,
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
        TextField(
          controller: pinController,
          enabled: !isNavigating,
          decoration: InputDecoration(
            labelText: 'PIN (4-6 dígitos)',
            labelStyle: const TextStyle(color: Colors.white),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightGreen),
            ),
            counterStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            suffixIcon: IconButton(
              onPressed: onCancel,
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          cursorColor: Colors.green,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white70,
            foregroundColor: Colors.black,
          ),
          child: isNavigating
              ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 15),
              Text('Iniciando...', style: TextStyle(fontSize: 18)),
            ],
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_kabaddi, size: 24),
              SizedBox(width: 15),
              Text('Salvar Jogador', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }

  static Widget buildPlayersList({
    required List<Map<String, dynamic>> players,
    required VoidCallback onToggleOverlay,
  }) {
    if (players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            const SizedBox(height: 80),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  tooltip: 'Mais informações',
                  onPressed: onToggleOverlay,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onToggleOverlay,
                    child: const Card(
                      color: Colors.white10,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Por que devo adicionar jogadores?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        const Align(
          alignment: Alignment.topCenter,
          child: Text(
            'Jogadores:',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
        ListView.builder(
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return ListTile(
              leading: const Icon(FontAwesomeIcons.userNinja, color: Colors.white),
              title: Text(player['nome'], style: const TextStyle(color: Colors.white)),
            );
          },
        ),
      ],
    );
  }

  static Widget buildStartGameButton({
    required bool canStart,
    required bool isNavigating,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canStart ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canStart ? Colors.white70 : Colors.grey,
          foregroundColor: canStart ? Colors.black : Colors.white54,
        ),
        child: isNavigating
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 15),
            Text('Iniciando...', style: TextStyle(fontSize: 18)),
          ],
        )
            : const Row(
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
}