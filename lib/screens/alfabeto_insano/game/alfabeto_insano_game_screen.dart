import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/widget/contra_o_tempo/timer_sound_manager.dart';

class AlfabetoInsanoGameScreen extends StatefulWidget {
  final int time;
  const AlfabetoInsanoGameScreen({super.key, required this.time});

  @override
  State<AlfabetoInsanoGameScreen> createState() => _AlfabetoInsanoGameScreenState();
}

class _AlfabetoInsanoGameScreenState extends State<AlfabetoInsanoGameScreen> with SingleTickerProviderStateMixin {

  bool timeUp = false;
  late int timeLeft;
  Timer? gameTimer;
  late AnimationController _timerController;
  late final TimerSoundManager _soundManager;

  late String currentCategory;
  late String currentLetter;

  // Lista para controlar as últimas categorias selecionadas
  List<String> lastCategories = [];

  @override
  void initState() {
    super.initState();
    // Tornar a barra de status transparente
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    timeLeft = widget.time;
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.time),
    );
    _soundManager = TimerSoundManager();
    _startGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _timerController.dispose();
    _soundManager.dispose();
    super.dispose();
  }

  List<String> categories = [
    'Animais',
    'Frutas',
    'Cores',
    'Países',
    'Profissões',
    'Esportes',
    'Objetos',
    'Comidas/Alimentos',
    'Bebidas',
    'Músicas',
    'Famosos',
    'Filmes/Séries',
    'Marcas',
    'Sentimentos',
    'Partes do Corpo',
    'Roupas/Acessórios',
  ];

  List<String> alphabet = List.generate(26, (index) => String.fromCharCode(65 + index)); // Letras de A a Z

  Color get colorTimer {
    // Usar a mesma lógica de _getProgressColor para manter consistência
    double currentAngle = ((_timerController.value * 360) + 90) % 360;

    // Definir cores baseadas na posição dos mascotes no background
    if (currentAngle >= 90 && currentAngle < 181) {
      // Inferior esquerdo - Verde (onde começa o ponteiro)
      return Colors.green;
    } else if (currentAngle > 181 && currentAngle < 271) {
      // Superior esquerdo - Azul
      return Colors.blue;
    } else if (currentAngle > 271 && currentAngle < 360) {
      // Superior direito - Laranja
      return Colors.orange;
    } else {
      // Inferior direito - Vermelho (0 a 90)
      return Colors.red;
    }
  }

  String _selectRandomCategory() {
    List<String> availableCategories = [...categories];

    // Se tivermos 2 categorias consecutivas iguais, remover essa categoria das opções
    if (lastCategories.length >= 2 &&
        lastCategories[lastCategories.length - 1] == lastCategories[lastCategories.length - 2]) {
      availableCategories.removeWhere((cat) => cat == lastCategories.last);
    }

    // Selecionar categoria aleatória das disponíveis
    String selectedCategory = (availableCategories..shuffle()).first;

    // Adicionar à lista de últimas categorias
    lastCategories.add(selectedCategory);

    // Manter apenas as últimas 3 categorias
    if (lastCategories.length > 3) {
      lastCategories.removeAt(0);
    }

    return selectedCategory;
  }

  void _startGame() {
    currentCategory = _selectRandomCategory();
    currentLetter = (alphabet..shuffle()).first;

    setState(() {
      timeLeft = widget.time;
      timeUp = false;
    });

    gameTimer?.cancel();
    _timerController.reset();
    _timerController.forward();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
          _soundManager.onTick(timeLeft);
        } else {
          timeUp = true;
          gameTimer?.cancel();
          _soundManager.playTimeUp();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        actionsPadding: EdgeInsets.all(12),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.backgroundAlfabetoInsano),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Espaço para a barra de status
            SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),

            // Conteúdo do jogo
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: timeUp
                    ? Column(
                        children: [
                          SizedBox(height: 50,),
                          Text(
                            'Tempo Esgotado!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black54,
                                  offset: Offset(2.0, 2.0),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _startGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text('Próxima Rodada'),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          // Categoria
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              currentCategory,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // Letra
                          Column(
                            children: [
                              SizedBox(height: 10,),
                              Text(
                                'Com a Letra:',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Colors.black54,
                                      offset: Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: colorTimer,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  currentLetter,
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 125,),

                          // Timer circular com ponteiro
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Timer circular
                                CustomPaint(
                                  size: Size(200, 200),
                                  painter: CircularTimerPainter(
                                    progress: _timerController.value,
                                    timeLeft: timeLeft,
                                  ),
                                ),
                                // Texto do tempo no centro
                                Text(
                                  _formatTime(timeLeft),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: colorTimer,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 5.0,
                                        color: Colors.black54,
                                        offset: Offset(1.0, 1.0),
                                      ),
                                    ],
                                  ),
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
      ),
    );
  }
}

// Custom Painter para o timer circular com ponteiro
class CircularTimerPainter extends CustomPainter {
  final double progress;
  final int timeLeft;

  CircularTimerPainter({required this.progress, required this.timeLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Círculo de fundo
    final backgroundPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Círculo de progresso
    final progressPaint = Paint()
      ..color = _getProgressColor()
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Desenhar o arco de progresso (começa de baixo e vai no sentido horário)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi / 2, // Começar de baixo (90 graus)
      2 * pi * progress, // Progresso no sentido horário
      false,
      progressPaint,
    );

    // Ponteiro (começa de baixo e vai no sentido horário)
    final pointerAngle = pi / 2 + (2 * pi * progress);
    final pointerEnd = Offset(
      center.dx + radius * cos(pointerAngle),
      center.dy + radius * sin(pointerAngle),
    );

    final pointerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Desenhar o ponteiro
    canvas.drawLine(center, pointerEnd, pointerPaint);

    // Círculo central do ponteiro
    final centerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, centerCirclePaint);
  }

  Color _getProgressColor() {
    // Calcular o ângulo atual baseado no progresso (0 a 360 graus)
    // Como começamos em 90 graus (centro inferior), precisamos ajustar
    double currentAngle = ((progress * 360) + 90) % 360;

    // Definir cores baseadas na posição dos mascotes no background
    if (currentAngle >= 90 && currentAngle < 181) {
      // Inferior esquerdo - Verde (onde começa o ponteiro)
      return Colors.green;
    } else if (currentAngle > 181 && currentAngle < 271) {
      // Superior esquerdo - Azul
      return Colors.blue;
    } else if (currentAngle > 271 && currentAngle < 360) {
      // Superior direito - Laranja
      return Colors.orange;
    } else {
      // Inferior direito - Vermelho (0 a 90)
      return Colors.red;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
