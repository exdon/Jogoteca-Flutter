import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jogoteca/screens/prazer_anonimo/adult_content_notify.dart';
import 'package:jogoteca/screens/prazer_anonimo/rules_screen.dart';
import 'package:jogoteca/screens/voce_me_conhece/voce_me_conhece_rules_screen.dart';

import '../widget/transicao.dart';
import 'menu_gestao/menu_gestao_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildFloatingButton(context),
      body: Stack(
        children: [
          _buildBackground(),
          _buildOverlay(),
          SafeArea(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MenuGestaoScreen()),
      ),
      backgroundColor: Colors.deepOrangeAccent,
      foregroundColor: Colors.white,
      tooltip: 'Menu de Gestão',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.settings),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Image.asset(
        "images/background_game.jpg",
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTitle(),
              const SizedBox(height: 10),
              _buildSubtitle(),
              const SizedBox(height: 5),
              _buildInstruction(),
              const SizedBox(height: 50),
              _buildGameButtons(context),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() => const Text(
    'Bem-vindo',
    style: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      shadows: [_defaultShadow],
    ),
  );

  Widget _buildSubtitle() => const Text(
    'Vamos jogar?',
    style: TextStyle(
      fontSize: 24,
      color: Colors.white,
      shadows: [_defaultShadow],
    ),
  );

  Widget _buildInstruction() => const Text(
    'Escolha um jogo abaixo',
    style: TextStyle(
      fontSize: 18,
      color: Colors.white70,
      shadows: [Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black38)],
    ),
  );

  void _adultContentNotifyDialog(BuildContext context, Widget telaDestino) {
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blueGrey,
        title: Text(
          'ATENÇÃO!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("images/18+_logo.webp", fit: BoxFit.cover),
                Text(
                  'Este jogo tem conteúdo recomendado apenas para maiores de 18 anos',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 50,),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFcf150e),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: Text('ME TIRE DAQUI')
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Transicao(telaDestino: telaDestino),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0e8f0a),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: Text('OK, SOU MAIOR DE IDADE'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          _buildGameButton(
            context,
            icon: FontAwesomeIcons.commentsDollar,
            label: 'Prazer, Anônimo!',
            color: Colors.white70,
            textColor: Colors.black,
            target: const RulesScreen(),
            alertContent: true
          ),
          const SizedBox(height: 15),
          _buildGameButton(
            context,
            icon: FontAwesomeIcons.wineBottle,
            label: 'Você me conhece?',
            color: Colors.white70,
            textColor: Colors.black,
            target: const VoceMeConheceRulesScreen(),
            alertContent: false
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildGameButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required Color textColor,
        required Widget target,
        required bool alertContent,
      }) {
    return ElevatedButton(
      onPressed: () => {
        alertContent
            ? _adultContentNotifyDialog(context, target)
            : Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Transicao(telaDestino: target),
                ),
            ),
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: const Size.fromHeight(50),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  static const Shadow _defaultShadow = Shadow(
    offset: Offset(1, 1),
    blurRadius: 3,
    color: Colors.black54,
  );
}
