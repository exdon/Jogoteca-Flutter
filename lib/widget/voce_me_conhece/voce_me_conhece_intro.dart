import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class VoceMeConheceIntro extends StatefulWidget {
  final VoidCallback onFinish;

  const VoceMeConheceIntro({super.key, required this.onFinish});

  @override
  State<VoceMeConheceIntro> createState() => _VoceMeConheceIntroState();
}

class _VoceMeConheceIntroState extends State<VoceMeConheceIntro>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _fadeQuestion;
  late AnimationController _fadeAnswers;
  late AnimationController _highlightWrong;
  late AnimationController _highlightRight;
  late AnimationController _finalTransition;

  String question = "Qual é o meu hobby favorito?";
  List<String> answers = [
    "Jogar videogame",
    "Viajar pelo mundo",
    "Cozinhar",
    "Praticar esportes"
  ];

  int? selectedWrong;
  int? selectedRight;

  @override
  void initState() {
    super.initState();

    _fadeQuestion = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnswers = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _highlightWrong = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _highlightRight = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _finalTransition = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Música ambiente neon
    await _audioPlayer.play(AssetSource('sounds/impact-intro.mp3'));

    // Mostra pergunta
    await _fadeQuestion.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    // Mostra respostas
    await _fadeAnswers.forward();
    await Future.delayed(const Duration(seconds: 1));

    // Seleciona errada
    setState(() => selectedWrong = 0);
    await _audioPlayer.play(AssetSource('sounds/wrong_answer.mp3'));
    await _highlightWrong.forward();
    await Future.delayed(const Duration(seconds: 2));

    // Seleciona certa
    setState(() {
      selectedWrong = null;
      selectedRight = 1;
    });
    await _audioPlayer.play(AssetSource('sounds/correct_answer.mp3'));
    await _highlightRight.forward();
    await Future.delayed(const Duration(seconds: 2));

    // Transição final bonita
    await _finalTransition.forward();
    await Future.delayed(const Duration(seconds: 3));

    widget.onFinish();
  }

  @override
  void dispose() {
    _fadeQuestion.dispose();
    _fadeAnswers.dispose();
    _highlightWrong.dispose();
    _highlightRight.dispose();
    _finalTransition.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neonGradient = const LinearGradient(
      colors: [Color(0xFF00FFFF), Color(0xFF8A2BE2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fundo de partículas neon com Lottie
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/lottie/Particle.json',
                fit: BoxFit.fill,
                repeat: true,
              ),
            ),
          ),

          // Pergunta
          FadeTransition(
            opacity: _fadeQuestion,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 180),
                child: ShaderMask(
                  shaderCallback: (bounds) => neonGradient.createShader(bounds),
                  child: Text(
                    question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 20, color: Colors.blueAccent, offset: Offset(0, 0))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Respostas
          FadeTransition(
            opacity: _fadeAnswers,
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(answers.length, (index) {
                  final isWrong = selectedWrong == index;
                  final isRight = selectedRight == index;

                  Color baseColor = Colors.white;
                  if (isWrong) baseColor = Colors.redAccent;
                  if (isRight) baseColor = Colors.greenAccent;

                  return AnimatedContainer(
                    width: double.infinity,
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: baseColor, width: 2),
                      boxShadow: [
                        if (isWrong)
                          BoxShadow(color: Colors.redAccent.withOpacity(0.6), blurRadius: 20),
                        if (isRight)
                          BoxShadow(color: Colors.greenAccent.withOpacity(0.6), blurRadius: 20),
                      ],
                    ),
                    child: Text(
                      answers[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: baseColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Transição final
          FadeTransition(
            opacity: _finalTransition,
            child: Container(
              color: Colors.black.withOpacity(0.9),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => neonGradient.createShader(bounds),
                  child: const Text(
                    "Você Me Conhece?",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 30, color: Colors.blueAccent, offset: Offset(0, 0))
                      ],
                    ),
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
