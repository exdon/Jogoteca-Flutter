import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/voce_me_conhece/players/players_bloc_vmc.dart';
import 'package:jogoteca/blocs/voce_me_conhece/players/players_event_vmc.dart';
import 'package:jogoteca/blocs/voce_me_conhece/players/players_state_vmc.dart';
import 'package:jogoteca/blocs/voce_me_conhece/questions/questions_bloc_vmc.dart';
import 'package:jogoteca/blocs/voce_me_conhece/questions/questions_state_vmc.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/constants/voce_me_conhece/voce_me_conhece_constants.dart';
import 'package:jogoteca/guards/game_pop_guard.dart';
import 'package:jogoteca/shared/shared_functions.dart';
import 'package:jogoteca/widget/app_bar_game.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum RadioEnum { verdade, mentira }
enum GamePhase { answering, voting, results, ranking, gameOver }

class VoceMeConheceGameScreen extends StatefulWidget {
  final String partidaId;
  const VoceMeConheceGameScreen({super.key, required this.partidaId});

  @override
  State<VoceMeConheceGameScreen> createState() => _VoceMeConheceGameScreenState();
}

class _VoceMeConheceGameScreenState extends State<VoceMeConheceGameScreen> {
  RadioEnum _radioOptions = RadioEnum.verdade;
  GamePhase _currentPhase = GamePhase.answering;

  bool _isLoading = true;
  bool _gameInitialized = false;
  bool _isRespostaExpanded = false;

  int indice = 0;
  List<Map<String, dynamic>> _players = [];
  Map<String, dynamic>? _currentQuestion;
  Map<String, dynamic>? _currentPlayer;

  // Controles para respostas
  List<TextEditingController> _textControllers = [];
  List<String> _addedOptions = [];
  String? _selectedMultipleChoice;
  String? _factBoolText;
  bool _isAnswerSubmitted = false;

  // Controles para votação
  Map<String, List<Map<String, dynamic>>> _votingOptions = {};
  List<String> _availableOptions = [];
  List<Map<String, dynamic>> _draggedPlayers = [];
  Set<String> _answeredQuestions = {};

  // Resultados
  final List<String> _wrongPlayers = [];
  Set<String> _recentlyUsedQuestions = {};

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Inicializar a primeira pergunta se ainda não foi definida
    if (_currentQuestion == null && _currentPlayer != null) {
      final questionsBlocState = context.read<QuestionsBlocVMC>().state;
      if (questionsBlocState is QuestionsLoadedVMC && questionsBlocState.questions.isNotEmpty) {
        _getRandomQuestion(questionsBlocState.questions);
      }
    }
  }

  void _getRandomQuestionSync(List<Map<String, dynamic>> questions) {
    if (questions.isEmpty) return;

    if (_currentPlayer == null) return;

    final availableQuestions = questions.where((q) =>
    !_answeredQuestions.contains('${_currentPlayer!['id']}_${q['id']}')
    ).toList();

    if (availableQuestions.isNotEmpty) {
      final random = Random();
      _currentQuestion = availableQuestions[random.nextInt(availableQuestions.length)];
    } else if (questions.isNotEmpty) {
      final random = Random();
      _currentQuestion = questions[random.nextInt(questions.length)];
    }
  }

  void _initializeControllers() {
    _textControllers = List.generate(5, (index) => TextEditingController());
  }

  void _resetControllers() {
    for (var controller in _textControllers) {
      controller.clear();
    }
    _addedOptions.clear();
    _selectedMultipleChoice = null;
    _factBoolText = null;
    _isAnswerSubmitted = false;
    _radioOptions = RadioEnum.verdade;
  }

  Future<void> _getRandomQuestion(List<Map<String, dynamic>> questions) async {
    if (questions.isEmpty || _currentPlayer == null) return;

    List<Map<String, dynamic>> availableQuestions = [];

    // Verificar quais perguntas o jogador atual ainda não respondeu
    for (var question in questions) {
      bool hasAnswered = await _hasPlayerAnsweredQuestion(_currentPlayer!['id'], question['id']);
      if (!hasAnswered) {
        availableQuestions.add(question);
      }
    }

    // Filtrar perguntas que não foram usadas recentemente
    List<Map<String, dynamic>> filteredQuestions = availableQuestions
        .where((q) => !_recentlyUsedQuestions.contains(q['id']))
        .toList();

    // Se não há perguntas não-recentes disponíveis, usar todas as disponíveis
    if (filteredQuestions.isEmpty) {
      filteredQuestions = availableQuestions;
      // Limpar histórico de perguntas recentes para permitir reutilização
      _recentlyUsedQuestions.clear();
    }

    if (filteredQuestions.isNotEmpty) {
      final random = Random();
      final selectedQuestion = filteredQuestions[random.nextInt(filteredQuestions.length)];

      if (mounted) {
        setState(() {
          _currentQuestion = selectedQuestion;
          // Adicionar pergunta ao conjunto de recentes
          _recentlyUsedQuestions.add(selectedQuestion['id']);

          // Manter apenas as últimas 3-5 perguntas no histórico
          if (_recentlyUsedQuestions.length > 3) {
            final questionsList = _recentlyUsedQuestions.toList();
            _recentlyUsedQuestions.clear();
            _recentlyUsedQuestions.addAll(questionsList.skip(1));
          }
        });
      }
    } else {
      // Se não há perguntas disponíveis, pode avançar para o próximo jogador
      SharedFunctions.showSnackMessage(message: 'Nenhuma pergunta disponível para ${_currentPlayer!['nome']}', mounted: mounted, context: context);
      _checkIfGameIsOver();
    }
  }

  Future<void> _checkIfGameIsOver() async {
    try {
      final hasQuestions = await context.read<PlayersBlocVMC>().service.hasAvailableQuestions(widget.partidaId);

      if (!hasQuestions) {
        // Não há mais perguntas disponíveis para nenhum jogador
        setState(() {
          _currentPhase = GamePhase.gameOver;
        });
      } else {
        // Ainda há perguntas, avançar para próximo jogador
        _nextPlayerOrEndGame();
      }
    } catch (e) {
      SharedFunctions.showSnackMessage(message: 'Erro ao verificar se jogo acabou: $e', mounted: mounted, context: context);
      // Em caso de erro, continuar normalmente
      _nextPlayerOrEndGame();
    }
  }

  void _nextPlayerOrEndGame() {
    if (indice < _players.length - 1) {
      _nextPlayer();
    } else {
      // Todos os jogadores terminaram, mostrar ranking
      _showRanking();
    }
  }

  Future<bool> _hasPlayerAnsweredQuestion(String playerId, String questionId) async {
    try {
      final response = await context.read<PlayersBlocVMC>().service.hasPlayerAnsweredQuestion(
        widget.partidaId,
        playerId,
        questionId,
      );
      return response;
    } catch (e) {
      SharedFunctions.showSnackMessage(message: 'Erro ao verificar pergunta respondida: $e', mounted: mounted, context: context);
      return false;
    }
  }

  void _submitAnswer() async {
    if (_isAnswerSubmitted) return;

    String answer = '';
    List<String> opcoesFalsas = [];
    bool? isTrue;

    switch (_currentQuestion!['tipo']) {
      case 'multi_texto':
        answer = _textControllers.last.text;
        opcoesFalsas = List.from(_addedOptions);
        break;
      case 'fato_bool':
        answer = _factBoolText ?? '';
        isTrue = _radioOptions == RadioEnum.verdade;
        break;
      case 'multipla_escolha':
        answer = _selectedMultipleChoice ?? '';
        break;
    }

    setState(() {
      _isAnswerSubmitted = true;
    });

    // Salvar resposta no banco
    await _savePlayerAnswer(answer, opcoesFalsas, isTrue);
  }

  Future<void> _savePlayerAnswer(String answer, List<String> opcoesFalsas, bool? isTrue) async {
    try {
      // Adicionar à lista local
      _answeredQuestions.add('${_currentPlayer!['id']}_${_currentQuestion!['id']}');

      context.read<PlayersBlocVMC>().add(
          SavePlayerAnswerVMC(
            partidaId: widget.partidaId,
            questionId: _currentQuestion!['id'],
            playerId: _currentPlayer!['id'],
            answer: answer,
            opcoesFalsas: opcoesFalsas,
            isTrue: isTrue,
          )
      );

      // Não adicionar LoadPlayersVMC aqui para evitar recarregamento desnecessário
    } catch (e) {
      SharedFunctions.showSnackMessage(message: 'Erro ao salvar resposta: $e', mounted: mounted, context: context);
      _answeredQuestions.remove('${_currentPlayer!['id']}_${_currentQuestion!['id']}');
      setState(() {
        _isAnswerSubmitted = false;
      });
    }
  }

  void _prepareVotingPhase() {
    setState(() {
      _currentPhase = GamePhase.voting;
      _votingOptions.clear();
      _draggedPlayers = _players.where((p) => p['id'] != _currentPlayer!['id']).toList();

      // Preparar opções baseadas no tipo da pergunta
      switch (_currentQuestion!['tipo']) {
        case 'multi_texto':
          _availableOptions = [..._addedOptions, _textControllers.last.text];
          _availableOptions.shuffle();
          break;
        case 'fato_bool':
        // Para fato_bool, mostrar o conteúdo digitado + as opções verdade/falso
          _availableOptions = ['Verdade', 'Mentira'];
          break;
        case 'multipla_escolha':
          _availableOptions = _getMultipleChoiceOptions();
          break;
      }

      // Verificar se _availableOptions não está vazio
      if (_availableOptions.isEmpty) {
        SharedFunctions.showSnackMessage(message: 'Erro: _availableOptions está vazio para tipo ${_currentQuestion!['tipo']}', mounted: mounted, context: context);
        return;
      }

      // Inicializar mapa de votação
      for (String option in _availableOptions) {
        _votingOptions[option] = [];
      }
    });
  }

  List<String> _getMultipleChoiceOptions() {
    final rawOptions = _currentQuestion!['options'];
    List<String> optionsList = [];

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
    return optionsList;
  }

  void _validateVotes() {
    String correctAnswer = '';

    switch (_currentQuestion!['tipo']) {
      case 'multi_texto':
        correctAnswer = _textControllers.last.text;
        break;
      case 'fato_bool':
      // Para fato_bool, a resposta correta é baseada no que o jogador escolheu (verdade/falso)
        correctAnswer = _radioOptions == RadioEnum.verdade ? 'Verdade' : 'Mentira';
        break;
      case 'multipla_escolha':
        correctAnswer = _selectedMultipleChoice ?? '';
        break;
    }

    _wrongPlayers.clear();

    for (String option in _votingOptions.keys) {
      List<Map<String, dynamic>> votersForOption = _votingOptions[option]!;
      bool isCorrect = option == correctAnswer;

      for (var voter in votersForOption) {
        if (!isCorrect) {
          _wrongPlayers.add(voter['nome']);
        }
        // Atualizar estatísticas do jogador
        _updatePlayerStats(voter['id'], isCorrect);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentPhase = GamePhase.results;
        });
      }
    });
  }

  void _updatePlayerStats(String playerId, bool isCorrect) {
    // Implementar atualização de estatísticas via BLoC
    context.read<PlayersBlocVMC>().add(
        UpdatePlayerStatsVMC(
          playerId: playerId,
          isCorrect: isCorrect,
        )
    );
  }

  void _nextPlayer() {
    if (indice < _players.length - 1) {
      setState(() {
        indice++;
        _currentPlayer = _players[indice];
        _currentPhase = GamePhase.answering;
        _resetControllers();
        _currentQuestion = null;
      });

      // Carregar jogadores atualizados
      context.read<PlayersBlocVMC>().add(LoadPlayersVMC(widget.partidaId));
    } else {
      _showRanking();
    }
  }

  void _showRanking() {
    setState(() {
      _currentPhase = GamePhase.ranking;
    });
  }

  void _startNewRound() {
    // Reset apenas estatísticas, votos e respostas - mantém perguntas respondidas
    context.read<PlayersBlocVMC>().add(ResetGameVMC(partidaId: widget.partidaId));

    setState(() {
      indice = 0;
      _currentPlayer = _players.isNotEmpty ? _players[0] : null;
      _currentPhase = GamePhase.answering;
      _currentQuestion = null;
      _resetControllers();
      // Limpar variáveis de controle
      _wrongPlayers.clear();
      _votingOptions.clear();
      _availableOptions.clear();
      _draggedPlayers.clear();
      _answeredQuestions.clear();
      _recentlyUsedQuestions.clear();
    });

    // Não usar delay, processar imediatamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Recarregar jogadores
        context.read<PlayersBlocVMC>().add(LoadPlayersVMC(widget.partidaId));
      }
    });
  }

  void _startNewGame() {
    // Reset completo incluindo perguntas respondidas
    context.read<PlayersBlocVMC>().add(ResetCompleteGameVMC(partidaId: widget.partidaId));

    setState(() {
      indice = 0;
      _currentPlayer = _players.isNotEmpty ? _players[0] : null;
      _currentPhase = GamePhase.answering;
      _currentQuestion = null;
      _resetControllers();
      // Limpar variáveis de controle
      _wrongPlayers.clear();
      _votingOptions.clear();
      _availableOptions.clear();
      _draggedPlayers.clear();
      _answeredQuestions.clear();
      _recentlyUsedQuestions.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PlayersBlocVMC>().add(LoadPlayersVMC(widget.partidaId));
      }
    });
  }

  List<Map<String, dynamic>> _getAllQuestions() {
    // Retornar todas as perguntas disponíveis
    return []; // Implementar via BLoC
  }

  @override
  Widget build(BuildContext context) {
    return GamePopGuard(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBarGame(
          disablePartida: true,
          deletePartida: true,
          partidaId: widget.partidaId,
          gameId: VoceMeConheceConstants.gameId,
          database: VoceMeConheceConstants.dbPartidas,
        ),
        body: Stack(
          children: [
            // Fundo
            Positioned.fill(
              child: Image.asset(AppConstants.backgroundVoceMeConhece, fit: BoxFit.cover),
            ),
            // Overlay escuro
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: BlocListener<PlayersBlocVMC, PlayersStateVMC>(
                  listener: (context, state) {

                    if (state is PlayerAnswerSavedVMC) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _currentPhase == GamePhase.answering) {
                          _prepareVotingPhase();
                        }
                      });
                    } else if (state is PlayersLoadedVMC && _currentPhase == GamePhase.ranking) {
                      // Forçar rebuild quando players são recarregados durante ranking
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {});
                        }
                      });
                    } else if (state is PlayersLoadedVMC && _currentPhase == GamePhase.answering && _currentQuestion == null) {
                      // Quando os jogadores são recarregados no início de uma nova rodada
                      final questionsBlocState = context.read<QuestionsBlocVMC>().state;
                      if (questionsBlocState is QuestionsLoadedVMC && questionsBlocState.questions.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            _getRandomQuestion(questionsBlocState.questions);
                          }
                        });
                      }
                    } else if (state is PlayersLoadedVMC && _currentPhase == GamePhase.answering) {
                      // Atualizar a lista local de jogadores quando recarregados
                      setState(() {
                        _players = List<Map<String, dynamic>>.from(state.players);
                        _players.sort((a, b) => (a['indice'] as int).compareTo(b['indice'] as int));
                        if (indice < _players.length) {
                          _currentPlayer = _players[indice];
                        }
                      });

                      // Se não tem pergunta, carregar uma nova
                      if (_currentQuestion == null) {
                        final questionsBlocState = context.read<QuestionsBlocVMC>().state;
                        if (questionsBlocState is QuestionsLoadedVMC && questionsBlocState.questions.isNotEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              _getRandomQuestion(questionsBlocState.questions);
                            }
                          });
                        }
                      }

                    } else if (state is PlayersErrorVMC) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro: ${state.message}')),
                      );
                      if (mounted) {
                        setState(() {
                          _isAnswerSubmitted = false;
                        });
                      }
                    }
                    // Remover outras reações para evitar interferência na fase de votação
                  },
                  child: BlocBuilder<PlayersBlocVMC, PlayersStateVMC>(
                    builder: (context, playersState) {
                      // Se estamos na fase de votação, não reagir a mudanças de estado dos jogadores
                      // Se estamos na fase de votação, resultados ou ranking, construir diretamente sem depender de estados
                      if (_currentPhase == GamePhase.voting || _currentPhase == GamePhase.results || _currentPhase == GamePhase.ranking) {
                        return _buildGameContent();
                      }

                      if (playersState is PlayersLoadedVMC) {
                        _players = List<Map<String, dynamic>>.from(playersState.players);
                        _players.sort((a, b) => (a['indice'] as int).compareTo(b['indice'] as int));

                        if (_players.isNotEmpty && indice < _players.length) {
                          _currentPlayer = _players[indice];
                        }

                        return BlocBuilder<QuestionsBlocVMC, QuestionsStateVMC>(
                          builder: (context, questionsState) {
                            if (questionsState is QuestionsLoadedVMC) {
                              if (!_gameInitialized && _currentPlayer != null) {
                                _gameInitialized = true;
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _getRandomQuestion(questionsState.questions);
                                });
                              }
                              return _buildGameContent();
                            } else if (questionsState is QuestionsLoadingVMC) {
                              return _buildLoadingState();
                            } else if (questionsState is QuestionsErrorVMC) {
                              return _buildErrorState(questionsState.message);
                            }
                            return _buildLoadingState();
                          },
                        );
                      } else if (playersState is PlayersLoadingVMC) {
                        return _buildLoadingState();
                      } else if (playersState is PlayersErrorVMC) {
                        return _buildErrorState(playersState.message);
                      }
                      return _buildLoadingState();
                    },
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameContent() {

    // Para fases que não dependem de questões carregadas, não verificar _currentQuestion
    if (_currentPhase == GamePhase.ranking) {
      return _buildRankingPhase();
    }

    if (_currentPhase == GamePhase.results) {
      return _buildResultsPhase();
    }

    // Verificar se dados essenciais estão disponíveis apenas para fases que precisam
    if (_currentPlayer == null) {
      return _buildLoadingState();
    }

    if ((_currentPhase == GamePhase.answering || _currentPhase == GamePhase.voting) && _currentQuestion == null) {
      return _buildLoadingState();
    }

    if (_currentPhase == GamePhase.gameOver) {
      return _buildGameOverPhase();
    }

    switch (_currentPhase) {
      case GamePhase.answering:
        return _buildAnsweringPhase();
      case GamePhase.voting:
        return _buildVotingPhase();
      case GamePhase.results:
        return _buildResultsPhase();
      case GamePhase.ranking:
        return _buildRankingPhase();
      case GamePhase.gameOver:
        return _buildGameOverPhase();
      default:
        return _buildLoadingState();
    }
  }

  Widget _buildAnsweringPhase() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              children: [
                _buildNeonContainer(
                  child: Column(
                    children: [
                      Text(
                        'Jogador da Vez',
                        style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _currentPlayer!['nome'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _buildNeonContainer(
                  child: Text(
                    _currentQuestion!['pergunta'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 30),
                _buildAnswerInput(),
                SizedBox(height: 20),
                _buildNeonButton(
                  text: 'Confirmar Resposta',
                  onPressed: _canSubmitAnswer() ? _submitAnswer : null,
                  color: Colors.green,
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerInput() {
    final tipo = _currentQuestion!['tipo'];
    final inputsCount = _currentQuestion!['inputs_count'] ?? 1;

    switch (tipo) {
      case 'multi_texto':
        return _buildMultiTextoInput(inputsCount);
      case 'fato_bool':
        return _buildFatoBoolInput();
      case 'multipla_escolha':
        return _buildMultiplaEscolhaInput();
      default:
        return _buildDefaultInput();
    }
  }

  Widget _buildMultiTextoInput(int inputsCount) {
    return Column(
      children: [
        Text(
          'Adicione primeiro ${inputsCount - 1} opções falsas',
          style: TextStyle(color: Colors.cyan, fontSize: 16),
        ),
        SizedBox(height: 20),
        // Opções adicionadas
        if (_addedOptions.isNotEmpty) ...[
          Text('Opções adicionadas:', style: TextStyle(color: Colors.white)),
          SizedBox(height: 10),
          ..._addedOptions.asMap().entries.map((entry) {
            return _buildNeonContainer(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${entry.key + 1}. ${entry.value}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _addedOptions.removeAt(entry.key);
                      });
                    },
                    icon: Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
            );
          }).toList(),
          SizedBox(height: 20),
        ],
        // Campo para adicionar nova opção
        if (_addedOptions.length < inputsCount - 1) ...[
          _buildNeonTextField(
            controller: _textControllers[_addedOptions.length],
            hint: 'Digite uma opção falsa',
          ),
          SizedBox(height: 10),
          _buildNeonButton(
            text: 'Adicionar Opção',
            onPressed: () {
              final text = _textControllers[_addedOptions.length].text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _addedOptions.add(text);
                  _textControllers[_addedOptions.length - 1].clear();
                });
              }
            },
            color: Colors.purple,
          ),
          SizedBox(height: 20),
        ],
        // Campo da resposta verdadeira
        if (_addedOptions.length == inputsCount - 1) ...[
          Text('Agora digite sua resposta verdadeira', style: TextStyle(color: Colors.green)),
          SizedBox(height: 10),
          _buildNeonTextField(
            controller: _textControllers.last,
            hint: 'Sua resposta verdadeira',
          ),
        ],
      ],
    );
  }

  Widget _buildFatoBoolInput() {
    return Column(
      children: [
        Text(
          'Conte algo sobre você:',
          style: TextStyle(color: Colors.cyan, fontSize: 16),
        ),
        SizedBox(height: 20),
        _buildNeonTextField(
          controller: _textControllers[0],
          hint: 'Digite algo sobre você...',
          onChanged: (value) {
            setState(() {
              _factBoolText = value;
            });
          },
        ),
        SizedBox(height: 30),
        Text(
          'Isso é verdade ou mentira?',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        SizedBox(height: 20),
        _buildNeonRadioButton(
          title: 'Verdade',
          value: RadioEnum.verdade,
          groupValue: _radioOptions,
          onChanged: (v) => setState(() => _radioOptions = v!),
        ),
        _buildNeonRadioButton(
          title: 'Mentira',
          value: RadioEnum.mentira,
          groupValue: _radioOptions,
          onChanged: (v) => setState(() => _radioOptions = v!),
        ),
      ],
    );
  }

  Widget _buildMultiplaEscolhaInput() {
    final options = _getMultipleChoiceOptions();

    return Column(
      children: [
        Text(
          'Escolha uma opção:',
          style: TextStyle(color: Colors.cyan, fontSize: 16),
        ),
        SizedBox(height: 20),
        ...options.asMap().entries.map((entry) {
          int index = entry.key;
          String option = entry.value;
          String optionLabel = String.fromCharCode(65 + index);
          bool isSelected = _selectedMultipleChoice == option;

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Material(
              color: isSelected ? Colors.cyan.withOpacity(0.3) : Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedMultipleChoice = option;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.cyan : Colors.purple.withOpacity(0.5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.cyan : Colors.purple,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            optionLabel,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            color: Colors.white,
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

  Widget _buildDefaultInput() {
    return _buildNeonTextField(
      controller: _textControllers[0],
      hint: 'Digite sua resposta...',
    );
  }

  bool _canSubmitAnswer() {
    if (_isAnswerSubmitted) return false;

    switch (_currentQuestion!['tipo']) {
      case 'multi_texto':
        final inputsCount = _currentQuestion!['inputs_count'] ?? 1;
        return _addedOptions.length == inputsCount - 1 && _textControllers.last.text.trim().isNotEmpty;
      case 'fato_bool':
        return _factBoolText != null && _factBoolText!.trim().isNotEmpty;
      case 'multipla_escolha':
        return _selectedMultipleChoice != null;
      default:
        return _textControllers[0].text.trim().isNotEmpty;
    }
  }

  Widget _buildVotingPhase() {
    return Column(
      children: [
        _buildNeonContainer(
          child: Column(
            children: [
              Text(
                'Vez de ${_currentPlayer!['nome']}',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                _currentQuestion!['pergunta'],
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              // Mostrar o conteúdo digitado para fato_bool
              if (_currentQuestion!['tipo'] == 'fato_bool' && _factBoolText != null) ...[
                SizedBox(height: 15),
                ExpansionPanelList(
                  elevation: 0,
                  expandIconColor: Colors.white,
                  expandedHeaderPadding: EdgeInsets.zero,
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      _isRespostaExpanded = !_isRespostaExpanded;
                    });
                  },
                  children: [
                    ExpansionPanel(
                      canTapOnHeader: true,
                      backgroundColor: Colors.transparent,
                      isExpanded: _isRespostaExpanded,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          title: Text(
                            'Ver resposta',
                            style: TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                        body: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple, width: 1),
                          ),
                          child: Text(
                            '"$_factBoolText"',
                            style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 20),
        _buildNeonContainer(
          child: Text(
            _currentQuestion!['tipo'] == 'fato_bool'
                ? 'Será que o que ${_currentPlayer!['nome']} disse é Verdade ou Mentira?'
                : 'Qual resposta vocês acham que ${_currentPlayer!['nome']} deu?',
            style: TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: Row(
            children: [
              Expanded(flex: 2, child: _buildPlayersList()),
              SizedBox(width: 20),
              Expanded(flex: 3, child: _buildVotingOptions()),
            ],
          ),
        ),
        SizedBox(height: 20),
        _buildNeonButton(
          text: 'Validar Votos',
          onPressed: _canValidateVotes() ? _validateVotes : null,
          color: Colors.green,
        ),
        SizedBox(height: 50,),
      ],
    );
  }

  Widget _buildPlayersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jogadores',
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: _draggedPlayers.length,
            itemBuilder: (context, index) {
              final player = _draggedPlayers[index];
              return Draggable<Map<String, dynamic>>(
                data: player,
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildPlayerChip(player, isDragging: true),
                ),
                childWhenDragging: _buildPlayerChip(player, isGhost: true),
                child: _buildPlayerChip(player),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerChip(Map<String, dynamic> player, {bool isDragging = false, bool isGhost = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isGhost
            ? Colors.grey.withOpacity(0.3)
            : isDragging
            ? Colors.cyan.withOpacity(0.8)
            : Colors.purple.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyan,
          width: 1,
        ),
      ),
      child: Text(
        player['nome'],
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildVotingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Respostas Possíveis',
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: _availableOptions.length,
            itemBuilder: (context, index) {
              final option = _availableOptions[index];
              final playersVotingForOption = _votingOptions[option] ?? [];

              return _buildVotingOptionCard(option, playersVotingForOption);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVotingOptionCard(String option, List<Map<String, dynamic>> voters) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: DragTarget<Map<String, dynamic>>(
        onAccept: (player) {
          setState(() {
            // Remove o jogador de outras opções
            _votingOptions.forEach((key, value) {
              value.removeWhere((p) => p['id'] == player['id']);
            });
            // Adiciona na opção atual
            _votingOptions[option]!.add(player);
            // Remove da lista de jogadores disponíveis
            _draggedPlayers.removeWhere((p) => p['id'] == player['id']);
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: candidateData.isNotEmpty ? Colors.cyan : Colors.purple.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                if (voters.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: voters.map((player) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            // Remove da opção atual e volta para lista de disponíveis
                            _votingOptions[option]!.removeWhere((p) => p['id'] == player['id']);
                            _draggedPlayers.add(player);
                          });
                        },
                        child: _buildPlayerChip(player),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Arraste jogadores aqui',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  bool _canValidateVotes() {
    // Verifica se todos os jogadores votaram
    final totalVotes = _votingOptions.values.fold<int>(0, (sum, voters) => sum + voters.length);
    return totalVotes == _players.length - 1; // -1 porque o jogador atual não vota
  }

  Widget _buildResultsPhase() {
    String correctAnswer = '';
    String resultText = '';

    switch (_currentQuestion!['tipo']) {
      case 'multi_texto':
        correctAnswer = _textControllers.last.text;
        resultText = 'A resposta correta era: "$correctAnswer"';
        break;
      case 'fato_bool':
        correctAnswer = _radioOptions == RadioEnum.verdade ? 'Verdade' : 'Mentira';
        resultText = 'A resposta para "$_factBoolText" é: $correctAnswer';
        break;
      case 'multipla_escolha':
        correctAnswer = _selectedMultipleChoice ?? '';
        resultText = 'A resposta correta era: "$correctAnswer"';
        break;
    }

    return Column(
      children: [
        _buildNeonContainer(
          child: Column(
            children: [
              Text(
                'Resultado',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Text(
                resultText,
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        if (_wrongPlayers.isNotEmpty) ...[
          _buildNeonContainer(
            child: Column(
              children: [
                Text(
                  'Jogadores que erraram:',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  _wrongPlayers.join(', '),
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ] else ...[
          _buildNeonContainer(
            child: Text(
              'Todos acertaram! 🎉',
              style: TextStyle(
                color: Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        Spacer(),
        _buildNeonButton(
          text: 'Próximo Jogador',
          onPressed: _nextPlayer,
          color: Colors.blue,
        ),
        SizedBox(height: 50,),
      ],
    );
  }

  Widget _buildRankingPhase() {
    final sortedPlayers = List<Map<String, dynamic>>.from(_players);
    sortedPlayers.sort((a, b) {
      final aScore = (a['acertos'] ?? 0) - (a['erros'] ?? 0);
      final bScore = (b['acertos'] ?? 0) - (b['erros'] ?? 0);
      return bScore.compareTo(aScore);
    });

    // Determinar jogadores com penalidade baseado na lógica correta
    List<Map<String, dynamic>> penaltyPlayers = [];

    if (sortedPlayers.isNotEmpty) {
      // Verificar se alguém acertou
      bool alguemAcertou = sortedPlayers.any((player) => (player['acertos'] ?? 0) > 0);

      if (!alguemAcertou) {
        // Se ninguém acertou, todos têm penalidade
        penaltyPlayers = List.from(sortedPlayers);
      } else {
        // Determinar quantos jogadores devem ter penalidade baseado no tamanho da lista
        int numPenalizados;
        if (sortedPlayers.length == 2) {
          numPenalizados = 1;  // apenas o último
        } else if (sortedPlayers.length > 2 && sortedPlayers.length < 5) {
          numPenalizados = 2;  // os 2 últimos
        } else {
          numPenalizados = 3;  // os 3 últimos
        }

        // Pegar os últimos jogadores para penalidade
        penaltyPlayers = sortedPlayers.sublist(
            sortedPlayers.length - numPenalizados
        );
      }
    }

    return Column(
      children: [
        _buildNeonContainer(
          child: Text(
            'Ranking Final',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: sortedPlayers.length,
            itemBuilder: (context, index) {
              final player = sortedPlayers[index];
              final isPenalty = penaltyPlayers.any((p) => p['id'] == player['id']);
              final position = index + 1;

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isPenalty
                      ? Colors.red.withOpacity(0.3)
                      : Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPenalty ? Colors.red : Colors.cyan,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: position <= 3
                            ? [Colors.amber, Colors.grey, Colors.brown][position - 1]
                            : Colors.purple,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$position°',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        player['nome'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'Acertos: ${player['acertos'] ?? 0}',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                        Text(
                          'Erros: ${player['erros'] ?? 0}',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (penaltyPlayers.isNotEmpty) ...[
          SizedBox(height: 20),
          _buildNeonContainer(
            child: Column(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 32),
                SizedBox(height: 8),
                Text(
                  penaltyPlayers.length == sortedPlayers.length
                      ? 'Penalidade para todos:'
                      : penaltyPlayers.length == 1
                        ? 'Penalidade para o último colocado:'
                        : 'Penalidade para os ${penaltyPlayers.length} últimos colocados:',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  penaltyPlayers.map((p) => p['nome']).join(', '),
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 20),
        _buildNeonButton(
          text: 'Nova Rodada',
          onPressed: _startNewRound,
          color: Colors.green,
        ),
        SizedBox(height: 50,),
      ],
    );
  }

  Widget _buildGameOverPhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNeonContainer(
          child: Column(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 64,
              ),
              SizedBox(height: 20),
              Text(
                'Fim de Jogo!',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Todas as perguntas foram respondidas por todos os jogadores!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 40),
        _buildNeonButton(
          text: 'Novo Jogo',
          onPressed: _startNewGame,
          color: Colors.green,
        ),
        SizedBox(height: 20),
        _buildNeonButton(
          text: 'Ver Ranking Final',
          onPressed: _showRanking,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildNeonContainer({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.cyan,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildNeonTextField({
    required TextEditingController controller,
    required String hint,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        autofocus: false,
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.multiline,
        minLines: 1,
        maxLines: null,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey),
          fillColor: Colors.black.withOpacity(0.5),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildNeonButton({
    required String text,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: onPressed != null ? [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ] : [],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? color.withOpacity(0.8) : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNeonRadioButton({
    required String title,
    required RadioEnum value,
    required RadioEnum groupValue,
    required Function(RadioEnum?) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value == groupValue ? Colors.cyan : Colors.purple.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: RadioListTile<RadioEnum>(
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: Colors.cyan,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
          ),
          SizedBox(height: 20),
          Text(
            'Carregando...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: _buildNeonContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'Erro',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _textControllers) {
      controller.dispose();
    }
    WakelockPlus.disable();
    super.dispose();
  }
}