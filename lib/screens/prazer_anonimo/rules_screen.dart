import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/players/players_bloc.dart';
import '../../service/firebase_service.dart';
import 'add_players_screen.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() =>
      _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  double _boxOpacity = 0.0;
  double _textOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _boxOpacity = 1.0);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() => _textOpacity = 1.0);
      });
    });
  }

  void _addPlayers() {
    String f(int n) => n.toString().padLeft(2, '0');
    String gerarNovaPartidaId() {
      final agora = DateTime.now();
      return "${agora.year}-${f(agora.month)}-${f(agora.day)}_${f(agora.hour)}:${f(agora.minute)}:${f(agora.second)}";
    }

    final String partidaId = gerarNovaPartidaId();

    final playersBloc = PlayersBloc(FirebaseService());
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: playersBloc,
          child: AddPlayersScreen(partidaId: partidaId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // fundo
          Positioned.fill(
            child:
            Image.asset("images/background_anonimo.jpg", fit: BoxFit.cover),
          ),

          // overlay escuro
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: _boxOpacity,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: AnimatedOpacity(
                              opacity: _textOpacity,
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeIn,
                              child: Text(
                                _regrasTexto,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildIniciarButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIniciarButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _addPlayers,
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: const Text('Iniciar', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey[900],
          textStyle: const TextStyle(fontSize: 20),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  final String _regrasTexto = '''
🎲 REGRAS DO JOGO 🎲

1. Primeira e mais importante: estamos em Vegas e tudo que acontece em Vegas, fica em Vegas. É estritamente proibido comentar sobre o que acontecer aqui.

2. Sobre as classificações:
   🌸 Moderado - Para aqueles que tomam leite em vez de cachaça. Apenas perguntas e desafios leves e engraçados.
   🔥 Picante - O céu é o limite! Aqui é diversão sem filtros. Só bora!
   🎰 Aleatório - Você quer pagar pra ver... o que vier é lucro!

3. Você tem 5 vidas.
   ❌ Perde uma vida se escolher não responder e/ou pagar.
   🍹 Perdeu uma vida? Beba uma bebida escolhida pelo grupo.
   ☠️ Acabaram as vidas? Agora é na marra. Sem escolha: responda ou pague.

4. 🩷 Você pode ganhar vidas durante o jogo. Você saberá quando 😉

Divirta-se e boa sorte!
''';
}
