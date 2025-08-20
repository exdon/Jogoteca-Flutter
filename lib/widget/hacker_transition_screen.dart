import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/screens/prazer_anonimo/game/game_screen.dart';

import '../blocs/players/players_bloc.dart';
import '../blocs/questions/questions_bloc.dart';
import '../blocs/questions/questions_event.dart';
import '../service/firebase_service.dart';
import 'matrix_code_rain.dart';

class HackerTransitionScreen extends StatefulWidget {
  final String partidaId;
  final PlayersBloc playersBloc;

  const HackerTransitionScreen({
    super.key,
    required this.partidaId,
    required this.playersBloc,
  });

  @override
  State<HackerTransitionScreen> createState() => _HackerTransitionScreenState();
}

class _HackerTransitionScreenState extends State<HackerTransitionScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _rainController;
  late AudioPlayer _audioPlayer;

  int fase = 1; // 1 = códigos, 2 = ponto piscando, 3 = digitando
  List<String> linhas = [
    "> Connecting to secure server...",
    "> Handshake complete.",
    "> Authentication granted.",
    "> Accessing mission parameters...",
    "> Loading encrypted data...",
    "> Mission data ready."
  ];

  List<String> linhasExibidas = [];
  String linhaAtualTexto = "";
  int linhaIndex = 0;
  int charIndex = 0;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();
    _startAudioConnect();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..repeat();

    // Controle de fases
    Timer(const Duration(seconds: 6), () {
      setState(() => fase = 2);

      // Depois do ponto piscando
      Timer(const Duration(seconds: 2), () {
        setState(() => fase = 3);
        _digitarProximaLinha();
      });
    });
  }

  void _startAudioConnect() async {
    // Inicia som em loop
    await _audioPlayer.play(AssetSource('sounds/connect.wav'), volume: 1, mode: PlayerMode.lowLatency);
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _digitarProximaLinha() {
    if (linhaIndex >= linhas.length) {

      _audioPlayer.stop();

      // Terminou tudo, vai pro jogo
      Timer(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: widget.playersBloc),
                BlocProvider(
                  create: (_) =>
                  QuestionsBloc(FirebaseService())..add(LoadQuestions()),
                ),
              ],
              child: GameScreen(partidaId: widget.partidaId),
            ),
          ),
        );
      });
      return;
    }

    charIndex = 0;
    linhaAtualTexto = "";
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (charIndex < linhas[linhaIndex].length) {
        setState(() {
          linhaAtualTexto += linhas[linhaIndex][charIndex];
          charIndex++;
        });
      } else {
        timer.cancel();
        linhasExibidas.add(linhaAtualTexto);
        linhaIndex++;
        Timer(const Duration(milliseconds: 300), _digitarProximaLinha);
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _rainController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fundo com movimento
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _bgController.value * 40 - 20),
                child: Image.asset(
                  "images/background_anonimo.jpg",
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          // Códigos (fase 1)
          if (fase == 1)
            AnimatedBuilder(
              animation: _rainController,
              builder: (context, child) {
                return CustomPaint(
                  painter: MatrixCodeRain(),
                );
              },
            ),
          // Ponto piscando (fase 2)
          if (fase == 2)
            Center(
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value > 0.5 ? 1 : 0,
                    child: const Text(
                      ".",
                      style: TextStyle(
                        fontSize: 48,
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                },
              ),
            ),
          // Linhas digitando (fase 3)
          if (fase == 3)
            Padding(
              padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.of(context).padding.top + 50,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var linha in linhasExibidas)
                      Text(
                        linha,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.greenAccent,
                          fontFamily: 'monospace',
                        ),
                      ),
                    Text(
                      linhaAtualTexto,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
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
}