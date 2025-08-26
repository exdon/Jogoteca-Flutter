import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:lottie/lottie.dart';

class GameIntroScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const GameIntroScreen({super.key, required this.onFinish});

  @override
  State<GameIntroScreen> createState() => _GameIntroScreenState();
}

class _GameIntroScreenState extends State<GameIntroScreen>
    with TickerProviderStateMixin {
  late AnimationController _angelController;
  late AnimationController _demonController;
  late AnimationController _textController;

  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool showAngel = false;
  bool showDemon = false;
  String displayedText = "";

  @override
  void initState() {
    super.initState();

    _angelController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _demonController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _textController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Música de fundo épica
    await _audioPlayer.play(AssetSource('sounds/intro_music.mp3'));

    // Angel aparece
    setState(() => showAngel = true);
    await _angelController.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setSpeechRate(0.5); // velocidade (0.5 = mais devagar, 1.0 = normal)
    await flutterTts.setPitch(0.7);      // tom (1.0 = normal, >1 mais agudo, <1 mais grave)

    // Texto "RESPONDA"
    setState(() => displayedText = "RESPONDA");
    await flutterTts.speak("Responda");
    await Future.delayed(const Duration(seconds: 2));

    // Texto "OU"
    setState(() => displayedText = "RESPONDA OU");
    await flutterTts.speak("ou");
    await Future.delayed(const Duration(seconds: 1));

    // Demon aparece
    setState(() => showDemon = true);
    await _demonController.forward();

    // Texto final "RESPONDA OU PAGUE"
    setState(() => displayedText = "RESPONDA OU PAGUE");
    await flutterTts.speak("Pague");

    // Efeito futurista extra
    await Future.delayed(const Duration(seconds: 3));
    widget.onFinish();
  }

  @override
  void dispose() {
    _angelController.dispose();
    _demonController.dispose();
    _textController.dispose();
    _audioPlayer.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo estático da imagem (sem personagens)
          Positioned.fill(
            child: Image.asset(
              AppConstants.rpBackgroundTransition, // você precisa recortar a imagem original tirando os personagens
              fit: BoxFit.cover,
            ),
          ),

          // Efeito de partículas futuristas
          Positioned.fill(
            child: Lottie.asset(AppConstants.lottieThunder,
                fit: BoxFit.fill),
          ),

          // Anjo aparecendo
          if (showAngel)
            FadeTransition(
              opacity: _angelController,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    AppConstants.rpAngelTransition,
                    height: 580,
                  ),
                ),
              ),
            ),

          // Demônio aparecendo
          if (showDemon)
            FadeTransition(
              opacity: _demonController,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Image.asset(
                    // fit: BoxFit.contain,
                    AppConstants.rpDemonTransition,
                    height: 580,
                  ),
                ),
              ),
            ),

          // Texto do título com efeito neon
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 200),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  displayedText,
                  key: ValueKey(displayedText),
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    shadows: [
                      Shadow(
                          blurRadius: 25,
                          color: Colors.orangeAccent.withOpacity(0.8),
                          offset: const Offset(0, 0))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
