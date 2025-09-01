import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/contra_o_tempo/players/players_bloc_ct.dart';
import 'package:jogoteca/blocs/contra_o_tempo/players/players_state_ct.dart';
import 'package:jogoteca/blocs/contra_o_tempo/questions/questions_bloc_ct.dart';
import 'package:jogoteca/blocs/contra_o_tempo/questions/questions_state_ct.dart';
import 'package:jogoteca/constants/contra_o_tempo/contra_o_tempo_constants.dart';
import 'package:jogoteca/guards/game_pop_guard.dart';
import 'package:jogoteca/screens/contra_o_tempo/game/game_helper_ct.dart';
import 'package:jogoteca/widget/app_bar_game.dart';
import 'package:jogoteca/widget/contra_o_tempo/timer_sound_manager.dart';

class ContraOTempoGameScreen extends StatefulWidget {
  final String partidaId;
  const ContraOTempoGameScreen({super.key, required this.partidaId});

  @override
  State<ContraOTempoGameScreen> createState() => _ContraOTempoGameScreenState();
}

class _ContraOTempoGameScreenState extends State<ContraOTempoGameScreen> with TickerProviderStateMixin {

  int currentPlayerIndex = 0;
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> availableQuestions = [];
  List<Map<String, dynamic>> usedQuestions = [];
  List<Map<String, dynamic>> correctAnsweredQuestions = []; // Perguntas respondidas corretamente
  bool showAnswer = false;
  bool timeUp = false;
  Timer? gameTimer;
  int timeLeft = 30;
  late AnimationController _timerController;
  bool isInitialized = false;

  // Variáveis para o sistema de opções
  String? selectedOption;
  bool showingOptions = false;
  bool optionSelected = false;
  bool answeredCorrectly = false;
  final TextEditingController _answerController = TextEditingController();
  String userAnswer = '';
  bool answerSubmitted = false;

  late final TimerSoundManager _soundManager;

  Color get colorTimer {
    if (timeLeft <= 10) {
      return Colors.red;
    } else if (timeLeft <= 15) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _soundManager = TimerSoundManager();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _timerController.dispose();
    _soundManager.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _initializeGame(List<Map<String, dynamic>> questions) {
    if (!isInitialized && questions.isNotEmpty) {
      // Não chamar setState aqui - apenas atualizar as variáveis
      availableQuestions = List.from(questions);
      isInitialized = true;
      _selectRandomQuestionWithoutSetState();
      // Use Future.delayed para iniciar o timer
      Future.delayed(Duration.zero, () {
        if (mounted) {
          _startTimer();
        }
      });
    }
  }

  void _selectRandomQuestionWithoutSetState() {
    if (availableQuestions.isNotEmpty) {
      currentQuestionIndex = Random().nextInt(availableQuestions.length);
    }
  }

  void _startTimer() {
    timeLeft = 30;
    timeUp = false;
    showAnswer = false;
    showingOptions = false;
    optionSelected = false;
    answeredCorrectly = false;
    selectedOption = null;
    _answerController.clear();
    userAnswer = '';
    answerSubmitted = false;
    gameTimer?.cancel();
    _timerController.reset();
    _timerController.forward();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        timeLeft--;
      });

      // toca o bip quando chegar em 10
      _soundManager.onTick(timeLeft);

      if (timeLeft <= 0) {
        timer.cancel();
        _soundManager.playTimeUp(); // alarme final
        setState(() {
          timeUp = true;
        });
      }
    });
  }

  void _showAnswer() {
    gameTimer?.cancel();
    _timerController.stop();
    _soundManager.stopAll();
    setState(() {
      showAnswer = true;
      // Move pergunta atual para usadas apenas se não tiver opções
      if (currentQuestionIndex < availableQuestions.length) {
        final currentQuestion = availableQuestions[currentQuestionIndex];
        bool hasOptions = currentQuestion['hasOptions'] == true;

        if (!hasOptions) {
          usedQuestions.add(availableQuestions[currentQuestionIndex]);
        }
      }
    });
  }

  void _selectOption(String option) {
    if (optionSelected || timeUp) return;

    gameTimer?.cancel();
    _timerController.stop();
    _soundManager.stopAll();

    final currentQuestion = availableQuestions[currentQuestionIndex];
    final correctAnswer = currentQuestion['resposta']?.toString() ?? '';
    final isCorrect = option == correctAnswer;

    setState(() {
      selectedOption = option;
      optionSelected = true;
      answeredCorrectly = isCorrect;
      showingOptions = true;
    });

    if (isCorrect) {
      // Se respondeu corretamente, move para perguntas respondidas corretamente
      correctAnsweredQuestions.add(currentQuestion);
    } else {
      // Se errou, apenas move para usadas (pode aparecer novamente)
      usedQuestions.add(currentQuestion);
    }
  }

  void _validateAnswer() {
    if (answerSubmitted || timeUp) return;

    gameTimer?.cancel();
    _timerController.stop();
    _soundManager.stopAll();

    final currentQuestion = availableQuestions[currentQuestionIndex];
    final correctAnswer = currentQuestion['resposta']?.toString() ?? '';

    // Função para normalizar texto (remover acentos e converter para minúscula)
    String normalizeText(String text) {
      return text
          .toLowerCase()
          .trim()
          .replaceAll('á', 'a')
          .replaceAll('à', 'a')
          .replaceAll('ã', 'a')
          .replaceAll('â', 'a')
          .replaceAll('ä', 'a')
          .replaceAll('é', 'e')
          .replaceAll('è', 'e')
          .replaceAll('ê', 'e')
          .replaceAll('ë', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ì', 'i')
          .replaceAll('î', 'i')
          .replaceAll('ï', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ò', 'o')
          .replaceAll('ô', 'o')
          .replaceAll('õ', 'o')
          .replaceAll('ö', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ù', 'u')
          .replaceAll('û', 'u')
          .replaceAll('ü', 'u')
          .replaceAll('ç', 'c')
          .replaceAll('ñ', 'n');
    }

    final normalizedCorrectAnswer = normalizeText(correctAnswer);
    final normalizedUserAnswer = normalizeText(userAnswer);

    // Verifica se é resposta exata ou se a resposta do usuário está contida na resposta correta
    bool isCorrect = false;

    if (normalizedUserAnswer == normalizedCorrectAnswer) {
      // Resposta exata
      isCorrect = true;
    } else if (normalizedCorrectAnswer.contains(normalizedUserAnswer) && normalizedUserAnswer.length >= 3) {
      // Resposta parcial (mínimo 3 caracteres para evitar coincidências)
      isCorrect = true;
    }

    setState(() {
      answerSubmitted = true;
      answeredCorrectly = isCorrect;
      if (isCorrect) {
        showAnswer = true;
      }
    });

    if (isCorrect) {
      // Se respondeu corretamente, move para perguntas respondidas corretamente
      correctAnsweredQuestions.add(currentQuestion);
    } else {
      // Se errou, apenas move para usadas (pode aparecer novamente)
      usedQuestions.add(currentQuestion);
    }
  }

  void _nextPlayer(List<Map<String, dynamic>> players) {
    // Remove pergunta atual da lista de disponíveis
    if (currentQuestionIndex < availableQuestions.length) {
      final currentQuestion = availableQuestions[currentQuestionIndex];
      final bool hasOptions = GameHelperCT.getHasOptions(currentQuestion);

      final bool shouldRemove = (!hasOptions && answerSubmitted && answeredCorrectly) || (hasOptions && answeredCorrectly);

      if (shouldRemove) {
        availableQuestions.removeAt(currentQuestionIndex);
      }
    }

    // Ordenar jogadores por índice para garantir ordem correta (1, 2, 3...)
    final sortedPlayers = List<Map<String, dynamic>>.from(players);
    sortedPlayers.sort((a, b) => (a['indice'] ?? 0).compareTo(b['indice'] ?? 0));

    setState(() {
      currentPlayerIndex = (currentPlayerIndex + 1) % sortedPlayers.length;
      timeLeft = 30;
      timeUp = false;
      showAnswer = false;
      showingOptions = false;
      optionSelected = false;
      answeredCorrectly = false;
      selectedOption = null;
      _answerController.clear();
      userAnswer = '';
      answerSubmitted = false;
    });

    _selectRandomQuestion();
    _startTimer();
  }

  void _selectRandomQuestion() {
    if (availableQuestions.isNotEmpty) {
      setState(() {
        currentQuestionIndex = Random().nextInt(availableQuestions.length);
      });
    }
  }

  void _restartGame(List<Map<String, dynamic>> allQuestions) {
    gameTimer?.cancel();
    _timerController.reset();
    _soundManager.stopAll();

    setState(() {
      currentPlayerIndex = 0;
      availableQuestions = List.from(allQuestions);
      usedQuestions.clear();
      correctAnsweredQuestions.clear();
      timeLeft = 30;
      timeUp = false;
      showAnswer = false;
      showingOptions = false;
      optionSelected = false;
      answeredCorrectly = false;
      selectedOption = null;
      _answerController.clear();
      userAnswer = '';
      answerSubmitted = false;
    });
    _selectRandomQuestion();

    // Usar Future.delayed para iniciar o timer
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GamePopGuard(
        partidaId: widget.partidaId,
        gameId: ContraOTempoConstants.gameId,
        database: ContraOTempoConstants.dbPartidas,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBarGame(
            disablePartida: true,
            deletePartida: true,
            partidaId: widget.partidaId,
            gameId: ContraOTempoConstants.gameId,
            database: ContraOTempoConstants.dbPartidas,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4A90E2),
                  Color(0xFF2E7BD6),
                  Color(0xFF1E5FA8),
                ],
              ),
            ),
            child: SafeArea(
              child: _buildContent(),
            ),
          ),
        ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<PlayersBlocCT, PlayersStateCT>(
      builder: (context, playersState) {
        if (playersState is PlayersLoadingCT) {
          return _buildLoading("Carregando jogador...");
        } else if (playersState is PlayersLoadedCT) {
          return BlocBuilder<QuestionsBlocCT, QuestionsStateCT>(
            builder: (context, questionsState) {
              if (questionsState is QuestionsLoadingCT) {
                return _buildLoading("Carregando perguntas...");
              } else if (questionsState is QuestionsLoadedCT) {
                // Inicializar perguntas apenas uma vez
                if (!isInitialized) {
                  _initializeGame(questionsState.questions);
                }

                // Se ainda não foi inicializado, mostrar loading
                if (!isInitialized) {
                  return _buildLoading("Preparando jogo...");
                }

                return _buildGameContent(playersState.players, questionsState.questions);
              } else if (questionsState is QuestionsErrorCT) {
                return Center(child: Text('Erro ao carregar perguntas: ${questionsState.message}', style: TextStyle(color: Colors.white)));
              }
              return const SizedBox.shrink();
            },
          );
        } else if (playersState is PlayersErrorCT) {
          return Center(child: Text('Erro: ${playersState.message}', style: TextStyle(color: Colors.white)));
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoading(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent(List<Map<String, dynamic>> players, List<Map<String, dynamic>> allQuestions) {
    // Verificar se acabaram as perguntas
    if (availableQuestions.isEmpty) {
      return _buildGameOver(allQuestions);
    }

    return Column(
      children: [
        // Header com timer e player
        _buildHeader(players),

        // Área principal do quiz
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: _buildQuestionCard(),
                ),
                const SizedBox(height: 20),
                _buildActionSection(players),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(List<Map<String, dynamic>> players) {
    if (players.isEmpty) return const SizedBox.shrink();

    // Ordenar jogadores por índice para garantir ordem correta (1, 2, 3...)
    final sortedPlayers = List<Map<String, dynamic>>.from(players);
    sortedPlayers.sort((a, b) => (a['indice'] ?? 0).compareTo(b['indice'] ?? 0));

    final currentPlayer = sortedPlayers[currentPlayerIndex];

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Player info
          Text(
            currentPlayer['nome'] ?? 'Jogador',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          // Timer
          _buildTimer(),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: CircularProgressIndicator(
              value: (timeLeft / 30),
              strokeWidth: 10,
              backgroundColor: Colors.grey[600],
              valueColor: AlwaysStoppedAnimation<Color>(colorTimer),
            ),
          ),
          Text(
            '$timeLeft',
            style: TextStyle(
              color: colorTimer,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1.5, 1.5),
                  blurRadius: 2.0,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    if (currentQuestionIndex >= availableQuestions.length) return const SizedBox.shrink();

    final question = availableQuestions[currentQuestionIndex];
    final bool hasOptions = GameHelperCT.getHasOptions(question);

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                question['pergunta'] ?? 'Pergunta não encontrada',
                style: const TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        SizedBox(height: 15,),
        Flexible(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: hasOptions && !timeUp
                  ? _buildOptions(question)
                  : _buildAnswerArea(question, hasOptions),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(Map<String, dynamic> question) {
    final correctAnswer = question['resposta']?.toString() ?? '';
    final rawOptions = question['options'];
    List<String> optionsList = [];

    // Extrai opções do campo 'options'
    if (rawOptions is List) {
      optionsList = rawOptions.map((e) => e.toString()).toList();
    } else if (rawOptions is String) {
      try {
        final decoded = jsonDecode(rawOptions);
        if (decoded is List) {
          optionsList = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    // Adiciona a resposta correta se não estiver na lista
    if (correctAnswer.isNotEmpty && !optionsList.contains(correctAnswer)) {
      optionsList.add(correctAnswer);
    }

    return Column(
      children: [
        ...optionsList.asMap().entries.map((entry) {
          int index = entry.key;
          String option = entry.value;
          String optionLabel = String.fromCharCode(65 + index); // A, B, C, D

          Color backgroundColor = Colors.grey[100]!;
          Color textColor = const Color(0xFF2C3E50);
          Color labelColor = const Color(0xFF2E7BD6);

          final isDisabled = optionSelected;

          if (optionSelected) {
            if (option == selectedOption) {
              // Se o usuário selecionou essa opção
              backgroundColor = (option == correctAnswer)
                  ? const Color(0xFF2ECC71) // Verde se acertou
                  : const Color(0xFFFF4757); // Vermelho se errou
              textColor = Colors.white;
              labelColor = Colors.white;
            } else {
              // Todas as outras opções ficam desabilitadas e neutras
              backgroundColor = Colors.grey[300]!;
              textColor = Colors.grey[600]!;
              labelColor = Colors.grey[600]!;
            }
          }


          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: isDisabled ? null : () => _selectOption(option),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: labelColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            optionLabel,
                            style: TextStyle(
                              color: (option == selectedOption) ? Colors.black : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAnswerArea(Map<String, dynamic> question, bool hasOptions) {
    if (!hasOptions && !timeUp && !answerSubmitted) {
      // Mostrar campo de input e botão validar
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _answerController,
              onChanged: (value) {
                setState(() {
                  userAnswer = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Digite sua resposta...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: userAnswer.trim().isEmpty ? null : _validateAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: userAnswer.trim().isEmpty
                    ? Colors.grey
                    : Colors.white,
                foregroundColor: const Color(0xFF2E7BD6),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'VALIDAR RESPOSTA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (!hasOptions && showAnswer) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF2ECC71).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2ECC71), width: 2),
          ),
          child: Text(
            question['resposta'] ?? 'Resposta não encontrada',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return const Center(
      child: Text(
        'Pense na resposta...',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildActionSection(List<Map<String, dynamic>> players) {
    final currentQuestion = currentQuestionIndex < availableQuestions.length
        ? availableQuestions[currentQuestionIndex]
        : null;
    final bool hasOptions = currentQuestion != null && GameHelperCT.getHasOptions(currentQuestion);

    // Se tem opções e uma foi selecionada, ou se o tempo acabou
    if ((hasOptions && optionSelected) || timeUp || (!hasOptions && answerSubmitted)) {
      return _buildResultSection(players);
    }

    // Se não tem opções e a resposta foi mostrada
    if (!hasOptions && answerSubmitted) {
      return _buildNextButton(players);
    }

    return const SizedBox.shrink();
  }

  Widget _buildNextButton(List<Map<String, dynamic>> players) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _nextPlayer(players),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2E7BD6),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Text(
          'PRÓXIMO JOGADOR',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection(List<Map<String, dynamic>> players) {
    String message = '';
    String buttonText = 'PRÓXIMO JOGADOR';
    Color resultColor = const Color(0xFF2E7BD6);
    IconData resultIcon = Icons.help;

    if (timeUp) {
      message = 'Oh não!\nTempo esgotado!';
      resultColor = const Color(0xFFFF4757);
      resultIcon = Icons.close;
    } else if (optionSelected || answerSubmitted) {
      if (answeredCorrectly) {
        message = 'Parabéns!\nResposta correta!';
        resultColor = const Color(0xFF2ECC71);
        resultIcon = Icons.check;
      } else {
        message = 'Que pena!\nResposta incorreta!';
        resultColor = const Color(0xFFFF4757);
        resultIcon = Icons.close;
      }
    }

    return Column(
      children: [
        if (message.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: resultColor, width: 2),
            ),
            child: Column(
              children: [
                Icon(
                  resultIcon,
                  color: resultColor,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    color: resultColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _nextPlayer(players),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2E7BD6),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameOver(List<Map<String, dynamic>> allQuestions) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7BD6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag,
                color: Color(0xFF2E7BD6),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Fim do Jogo!',
              style: TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Todas as perguntas foram respondidas',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _restartGame(allQuestions),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'JOGAR NOVAMENTE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}