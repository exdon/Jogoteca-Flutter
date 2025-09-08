import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WidgetsRPBuild {

  static Widget buildAddButton({
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.cyan.withOpacity(0.8),
            Colors.purple.withOpacity(0.6),
            Colors.cyan.withOpacity(0.4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const FaIcon(FontAwesomeIcons.userPlus, color: Colors.white, size: 20),
        label: const Text(
          'Adicionar Jogador',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
      padding: const EdgeInsets.all(16), // Reduzido de 20 para 16
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.cyan.withOpacity(0.08),
            Colors.purple.withOpacity(0.08),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Importante: usar min para economizar espaço
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: nomeController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: Colors.cyan,
              decoration: InputDecoration(
                labelText: 'Nome do jogador',
                labelStyle: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Colors.cyan.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Colors.cyan,
                    width: 2.5,
                  ),
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduzido vertical de 16 para 12
              ),
            ),
          ),
          const SizedBox(height: 16), // Reduzido de 24 para 16
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.withOpacity(0.8),
                  Colors.teal.withOpacity(0.6),
                  Colors.green.withOpacity(0.4),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12), // Reduzido de 16 para 12
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.sports_kabaddi, size: 20, color: Colors.white), // Reduzido de 24 para 20
                  SizedBox(width: 8), // Reduzido de 12 para 8
                  Text(
                    'Salvar Jogador',
                    style: TextStyle(
                      fontSize: 16, // Reduzido de 18 para 16
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
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

  static Widget buildPlayersList({
    required List<Map<String, dynamic>> players,
    bool isKeyboardOpen = false, // Novo parâmetro
  }) {
    if (players.isEmpty) {
      // Se teclado estiver aberto, mostrar apenas container vazio
      if (isKeyboardOpen) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text(
              'Lista de jogadores vazia',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      // Se teclado estiver fechado, mostrar mensagem completa
      return Container(
        padding: const EdgeInsets.all(32), // Voltou para um valor maior já que só aparece com teclado fechado
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.cyan.withOpacity(0.2),
                    Colors.purple.withOpacity(0.2),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                FontAwesomeIcons.userGroup,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum jogador cadastrado',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione jogadores para começar\na diversão!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400,
                fontSize: 15,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Título da seção
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.cyan.withOpacity(0.2),
                Colors.purple.withOpacity(0.1),
                Colors.cyan.withOpacity(0.05),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                FontAwesomeIcons.users,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Jogadores (${players.length})',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        // Lista de jogadores com scroll
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Column(
              children: players.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;
                return Container(
                  margin: EdgeInsets.only(
                    bottom: index == players.length - 1 ? 0 : 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.cyan.withOpacity(0.05),
                        Colors.purple.withOpacity(0.03),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    leading: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.cyan.withOpacity(0.6),
                            Colors.purple.withOpacity(0.4),
                          ],
                        ),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.userNinja,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    title: Text(
                      player['nome'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.6),
                            Colors.teal.withOpacity(0.4),
                          ],
                        ),
                      ),
                      child: Text(
                        '${index + 1}', // Mostra o índice do jogador (1, 2, 3, etc.)
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
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
    final bool isEnabled = onPressed != null;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: isEnabled ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.9),
            Colors.red.withOpacity(0.7),
            Colors.pink.withOpacity(0.6),
          ],
        ) : LinearGradient(
          colors: [
            Colors.grey.withOpacity(0.5),
            Colors.grey.withOpacity(0.3),
          ],
        ),
        boxShadow: isEnabled ? [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.dice,
              color: isEnabled ? Colors.white : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(width: 15),
            Text(
              'Iniciar Jogo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isEnabled ? Colors.white : Colors.grey.shade400,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
