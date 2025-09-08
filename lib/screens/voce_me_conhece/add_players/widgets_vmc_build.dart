import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WidgetsVMCBuild {

  static Widget buildAddButton({
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            Colors.cyan.withValues(alpha: 0.8),
            Colors.blue.withValues(alpha: 0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const FaIcon(FontAwesomeIcons.userPlus, color: Colors.white, size: 20),
        label: const Text(
          'Adicionar jogador',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            shadows: [
              Shadow(
                color: Colors.cyan,
                blurRadius: 5,
              ),
            ],
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  static Widget buildPlayerFields({
    required TextEditingController nomeController,
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyan,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: nomeController,
            decoration: InputDecoration(
              labelText: 'Nome do jogador',
              labelStyle: TextStyle(
                color: Colors.cyan.shade300,
                fontWeight: FontWeight.w500,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.cyan.shade400, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.cyan, width: 3),
              ),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.5),
              suffixIcon: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: Colors.cyan,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  Colors.green.withValues(alpha: 0.8),
                  Colors.lightGreen.withValues(alpha: 0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_kabaddi, size: 24, color: Colors.white),
                  SizedBox(width: 15),
                  Text(
                    'Salvar Jogador',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.green,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.purple.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.userGroup,
                  color: Colors.cyan,
                  size: 50,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nenhum jogador cadastrado',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    shadows: [
                      Shadow(
                        color: Colors.cyan,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Adicione jogadores para iniciar o jogo',
                  style: TextStyle(
                    color: Colors.cyan.shade300,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Lista de jogadores
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyan.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: players.length + 1, // +1 para o título
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withValues(alpha: 0.6),
                    Colors.blue.withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.userGroup, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Jogadores (${players.length})',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.purple,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          final player = players[index - 1];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.cyan.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.cyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.cyan.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: const Icon(FontAwesomeIcons.userNinja, color: Colors.cyan, size: 20),
              ),
              title: Text(
                player['nome'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${index}',
                  style: TextStyle(
                    color: Colors.purple.shade200,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
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
              color: Colors.black.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.cyan, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Por que adicionar jogadores?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Isso permite personalizar a experiência e registrar respostas individuais.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      foregroundColor: Colors.white,
                    ),
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
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: onPressed != null
            ? LinearGradient(
                colors: [
                  Colors.orange.withValues(alpha: 0.8),
                  Colors.deepOrange.withValues(alpha: 0.6),
                ],
              )
            : LinearGradient(
                colors: [
                  Colors.grey.withValues(alpha: 0.5),
                  Colors.grey.withValues(alpha: 0.3),
                ],
              ),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.dice,
              color: onPressed != null ? Colors.white : Colors.grey.shade400,
              size: 24,
            ),
            SizedBox(width: 15),
            Text(
              'Iniciar Jogo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: onPressed != null ? Colors.white : Colors.grey.shade400,
                shadows: onPressed != null
                    ? [
                        Shadow(
                          color: Colors.orange,
                          blurRadius: 5,
                        ),
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
