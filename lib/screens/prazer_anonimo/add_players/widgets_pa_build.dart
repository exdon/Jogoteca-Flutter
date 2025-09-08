import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetsPABuild {
  static const Color _hackerGreen = Color(0xFF39FF14); // Um verde neon mais brilhante
  static const Color _darkBackgroundColor = Colors.black;

  static TextStyle _hackerTextStyle(double fontSize, {FontWeight fontWeight = FontWeight.normal, Color color = _hackerGreen}) {
    return GoogleFonts.orbitron( // Fonte mais legível e futurista
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      shadows: [
        Shadow(
          blurRadius: 5.0,
          color: color.withOpacity(0.5),
          offset: const Offset(0, 0),
        ),
      ],
    );
  }

  static Widget buildAddButton({
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const FaIcon(FontAwesomeIcons.userPlus, color: _hackerGreen, size: 18),
      label: Text(
        'Adicionar jogador',
        style: _hackerTextStyle(18),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: const BorderSide(color: _hackerGreen, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  static Widget buildPlayerFields({
    required TextEditingController nomeController,
    required TextEditingController pinController,
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: nomeController,
            decoration: _inputDecoration('Nome do jogador', onCancel),
            style: _hackerTextStyle(16, color: Colors.white),
            cursorColor: _hackerGreen,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: pinController,
            decoration: _inputDecoration('PIN (4-6 dígitos)', onCancel),
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            style: _hackerTextStyle(16, color: Colors.white),
            cursorColor: _hackerGreen,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(FontAwesomeIcons.save, color: Colors.black),
            label: Text(
              'Salvar Jogador',
              style: GoogleFonts.orbitron(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _hackerGreen,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }

  static InputDecoration _inputDecoration(String label, VoidCallback onCancel) {
    return InputDecoration(
      labelText: label,
      labelStyle: _hackerTextStyle(16),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _hackerGreen),
        borderRadius: BorderRadius.circular(4),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _hackerGreen, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      counterStyle: _hackerTextStyle(14),
      suffixIcon: IconButton(
        onPressed: onCancel,
        icon: const Icon(Icons.close, color: _hackerGreen),
      ),
    );
  }

  static Widget buildPlayersList({
    required List<Map<String, dynamic>> players,
    required VoidCallback onToggleOverlay,
  }) {
    if (players.isEmpty) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Text(
                'Nenhum jogador cadastrado',
                style: _hackerTextStyle(20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Adicione jogadores para iniciar o jogo',
                style: _hackerTextStyle(16),
              ),
              const SizedBox(height: 50),
              GestureDetector(
                onTap: onToggleOverlay,
                child: Card(
                  color: Colors.black.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: _hackerGreen, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: _hackerGreen),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Por que devo adicionar jogadores?',
                            style: _hackerTextStyle(15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Jogadores:',
            style: _hackerTextStyle(22, fontWeight: FontWeight.bold),
          ),
        ),
        ...players.map((player) => ListTile(
          leading: const FaIcon(FontAwesomeIcons.userNinja, color: _hackerGreen),
          title: Text(
            player['nome'],
            style: _hackerTextStyle(18, color: Colors.white),
          ),
        )),
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
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: Material(
          color: Colors.black.withOpacity(0.9),
          child: Center(
            child: Container(
              width: screenSize.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _darkBackgroundColor,
                border: Border.all(color: _hackerGreen, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Por que adicionar jogadores?',
                    style: _hackerTextStyle(20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Isso permite personalizar a experiência e registrar respostas individuais.',
                    textAlign: TextAlign.center,
                    style: _hackerTextStyle(16, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: onClose,
                    child: Text(
                      'Fechar',
                      style: _hackerTextStyle(16),
                    ),
                  ),
                ],
              ),
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
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(FontAwesomeIcons.play, color: onPressed != null ? Colors.black : Colors.grey[700], size: 18),
        label: Text(
          'Iniciar Jogo',
          style: GoogleFonts.orbitron(
            color: onPressed != null ? Colors.black : Colors.grey[700],
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _hackerGreen,
          disabledBackgroundColor: _hackerGreen.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
