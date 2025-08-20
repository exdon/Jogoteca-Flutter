import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/screens/prazer_anonimo/add_players/add_players_screen.dart';
import 'package:jogoteca/screens/prazer_anonimo/rules/rules_constants.dart';

import '../../../blocs/players/players_bloc.dart';
import '../../../service/firebase_service.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  double _boxOpacity = 0.0;
  double _textOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _boxOpacity = 1.0);

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() => _textOpacity = 1.0);
      });
    });
  }

  void _navigateToAddPlayers() {
    final String partidaId = _generatePartidaId();
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

  String _generatePartidaId() {
    String f(int n) => n.toString().padLeft(2, '0');
    final agora = DateTime.now();
    return "${agora.year}-${f(agora.month)}-${f(agora.day)}_${f(agora.hour)}:${f(agora.minute)}:${f(agora.second)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        // Fundo
        Positioned.fill(
          child: Image.asset("images/background_anonimo.jpg", fit: BoxFit.cover),
        ),
        // Overlay escuro
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 50),
            _buildRulesContainer(),
            const SizedBox(height: 16),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesContainer() {
    return Expanded(
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
                child: const Text(
                  RulesConstants.rulesText,
                  style: TextStyle(
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
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _navigateToAddPlayers,
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: const Text('Iniciar', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey[900],
          textStyle: const TextStyle(fontSize: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}