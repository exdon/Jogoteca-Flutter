import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jogoteca/blocs/responda_ou_pague/challenges/challenges_bloc_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/challenges/challenges_event_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/challenges/challenges_state_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/players/players_bloc_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/players/players_event_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/players/players_state_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/questions/questions_bloc_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/questions/questions_event_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/questions/questions_state_rp.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/constants/responda_ou_pague/responda_ou_pague_constants.dart';
import 'package:jogoteca/widget/app_bar_game.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum GameStep {
  generatePlayer,
  selectCategory,
  showQuestion,
  showChallenge,
}

class RespondaOuPagueGameScreen extends StatefulWidget {
  final String partidaId;
  const RespondaOuPagueGameScreen({super.key, required this.partidaId});

  @override
  State<RespondaOuPagueGameScreen> createState() => _RespondaOuPagueGameScreenState();
}

class _RespondaOuPagueGameScreenState extends State<RespondaOuPagueGameScreen> {
  GameStep currentStep = GameStep.generatePlayer;
  String? currentPlayerName;
  String? currentPlayerId;
  int? currentPlayerLives;
  String? selectedCategory;
  Map<String, dynamic>? currentQuestion;
  Map<String, dynamic>? currentChallenge;
  List<Map<String, dynamic>>? allPlayers; // Lista de todos os jogadores

  Map<String, Set<String>> playersAnsweredQuestions = {}; // Chave: playerId, Valor: Set de question IDs
  Map<String, Set<String>> playersCompletedChallenges = {}; // Chave: playerId, Valor: Set de challenge IDs
  Set<String> recentlyUsedQuestions = {}; // IDs das perguntas usadas recentemente
  Set<String> recentlyUsedChallenges = {}; // IDs dos desafios usados recentemente

  StreamController<int?> selectedPlayerController = StreamController<int?>.broadcast();
  bool isSpinning = false;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    context.read<PlayersBlocRP>().add(LoadPlayersRP(widget.partidaId));
    _resetGame();
  }

  @override
  void dispose() {
    selectedPlayerController.close();
    WakelockPlus.disable();
    super.dispose();
  }


  void _resetGame() {
    _clearWheelSelection();

    setState(() {
      currentStep = GameStep.generatePlayer;
      currentPlayerName = null;
      currentPlayerId = null;
      currentPlayerLives = null;
      selectedCategory = null;
      currentQuestion = null;
      currentChallenge = null;
      selectedIndex = null;
      isSpinning = false;
    });

    // Reset dos BLoCs
    context.read<PlayersBlocRP>().add(LoadPlayersRP(widget.partidaId));
    context.read<QuestionsBlocRP>().add(ResetQuestionRP());
    context.read<ChallengesBlocRP>().add(ResetChallengeRP());
  }

  void _clearWheelSelection() {
    selectedPlayerController.add(null); // limpa o valor emitido
  }

  void _updateLives(int newLives) {
    context.read<PlayersBlocRP>().add(UpdatePlayerDataRP(widget.partidaId, currentPlayerId!, newLives));
    setState(() {
      currentPlayerLives = newLives;
    });
  }

  // Função para substituir {player} por um nome aleatório
  String _replacePlayerPlaceholder(String text) {
    if (!text.contains('{player}')) {
      return text;
    }

    if (allPlayers == null || allPlayers!.length <= 1) {
      // Se não há outros jogadores, remove o placeholder
      return text.replaceAll('{player}', 'outro jogador');
    }

    // Filtra jogadores diferentes do atual
    final otherPlayers = allPlayers!.where((player) =>
    player['id'] != currentPlayerId
    ).toList();

    if (otherPlayers.isEmpty) {
      return text.replaceAll('{player}', 'outro jogador');
    }

    // Seleciona um jogador aleatório
    final random = Random();
    final randomPlayer = otherPlayers[random.nextInt(otherPlayers.length)];
    final randomPlayerName = randomPlayer['nome'] ?? 'outro jogador';

    return text.replaceAll('{player}', randomPlayerName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarGame(
        disablePartida: true,
        deletePartida: true,
        partidaId: widget.partidaId,
        gameId: RespondaOuPagueConstants.gameId,
        database: RespondaOuPagueConstants.dbPartidas,
      ),
      body: Stack(
        children: [
          // Fundo da imagem
          Positioned.fill(
            child: Image.asset(
              AppConstants.backgroundRespondaOuPague,
              fit: BoxFit.cover,
            ),
          ),
          // Overlay escuro
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          // Conteúdo principal
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildCurrentStep(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case GameStep.generatePlayer:
        return _buildGeneratePlayerStep();
      case GameStep.selectCategory:
        return _buildSelectCategoryStep();
      case GameStep.showQuestion:
        return _buildShowQuestionStep();
      case GameStep.showChallenge:
        return _buildShowChallengeStep();
    }
  }

  // PASSO 1: Gerar Jogador
  Widget _buildGeneratePlayerStep() {
    return BlocListener<PlayersBlocRP, PlayersStateRP>(
      listener: (context, state) {
        if (state is PlayersLoadedRP) {
          setState(() {
            allPlayers = state.players;
          });
        } else if (state is PlayersErrorRP) {
          _showErrorSnackBar("Erro ao carregar jogadores: ${state.message}");
        }
      },
      child: BlocBuilder<PlayersBlocRP, PlayersStateRP>(
        builder: (context, state) {
          if (state is PlayersLoadingRP || allPlayers == null) {
            return _buildLoading("Carregando jogadores...");
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bem-vindo(a) ao',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Responda ou Pague!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              SizedBox(
                height: 300,
                child: FortuneWheel(
                  selected: selectedPlayerController.stream.where((value) => value != null).cast<int>(),
                  items: allPlayers!.map((player) {
                    return FortuneItem(
                      child: Text(
                        player['nome'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  animateFirst: false,
                  onAnimationEnd: () {
                    if (selectedIndex != null) {
                      final selectedPlayer = allPlayers![selectedIndex!];
                      setState(() {
                        currentPlayerName = selectedPlayer['nome'];
                        currentPlayerId = selectedPlayer['id'];
                        currentStep = GameStep.selectCategory;
                        isSpinning = false;
                        selectedIndex = null;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Clique no botão abaixo para sortear um jogador e iniciar o jogo.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  onPressed: isSpinning
                      ? null
                      : () {
                    final index = Random().nextInt(allPlayers!.length);
                    selectedIndex = index; // salva o índice sorteado
                    selectedPlayerController.add(index);
                    setState(() {
                      isSpinning = true;
                    });
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Girar', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 8),
                      FaIcon(FontAwesomeIcons.arrowsRotate),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  // PASSO 2: Selecionar Categoria
  Widget _buildSelectCategoryStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.person,
          size: 80,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        const Text(
          'Jogador Sorteado:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          currentPlayerName ?? 'Jogador não encontrado',
          style: const TextStyle(
            color: Colors.deepOrange,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Selecione uma categoria:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildCategoryButton('moderado', 'Moderado'),
            _buildCategoryButton('picante', 'Picante'),
            _buildCategoryButton('aleatorio', 'Aleatório'),
          ],
        ),
        if (selectedCategory != null) ...[
          const SizedBox(height: 80),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _getColor(selectedCategory!),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              ),
              onPressed: () {
                // Pega perguntas já respondidas pelo jogador atual
                final playerQuestions = playersAnsweredQuestions[currentPlayerId] ?? <String>{};

                context.read<QuestionsBlocRP>().add(LoadQuestionRP(
                    selectedCategory!,
                    playerQuestions.toList(),
                    recentlyUsedQuestions.toList()
                ));
                context.read<PlayersBlocRP>().add(LoadPlayerDataRP(widget.partidaId, currentPlayerId!));
                setState(() {
                  currentStep = GameStep.showQuestion;
                });
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text(
                    'Iniciar Jogo',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryButton(String value, String label) {
    final bool isSelected = selectedCategory == value;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _getColor(value),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isSelected ? const BorderSide(color: Colors.white, width: 2) : BorderSide.none,
        ),
      ),
      onPressed: () {
        setState(() {
          selectedCategory = value;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (selectedCategory == value)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: _iconeClassificacao(value),
            ),
        ],
      ),
    );
  }

  Icon? _iconeClassificacao(String valor) {
    if (selectedCategory != valor) return null;

    switch (valor) {
      case 'moderado':
        return const Icon(Icons.local_florist, color: Colors.white, size: 20);
      case 'picante':
        return const Icon(Icons.local_fire_department, color: Colors.white, size: 20);
      case 'aleatorio':
        return const Icon(Icons.shuffle, color: Colors.white, size: 20);
    }

    return null;
  }

  Color? _getColor(String value) {
    final bool isSelected = selectedCategory == value;

    switch (value) {
      case 'moderado':
        return _getTypeColor(isSelected, Colors.green.shade600);
      case 'picante':
        return _getTypeColor(isSelected, Colors.red);
      case 'aleatorio':
        return _getTypeColor(isSelected, Colors.purple);
    }
    return Colors.grey;
  }

  Color? _getTypeColor(bool isSelected, Color color) {
    return isSelected ? color : color.withOpacity(0.3);
  }

  Widget _buildPlayerInfoBar() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.person, size: 40, color: Colors.deepOrange,),
                SizedBox(width: 8,),
                Expanded(
                  child: Text(
                    currentPlayerName ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,         // permite quebra automática
                    overflow: TextOverflow.visible, // não corta o texto
                    maxLines: 2,            // limite de linhas para não ocupar demais
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: currentPlayerLives != null
                    ? () => _updateLives(currentPlayerLives! - 1)
                    : null,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 40,
                  ),
                  Text(
                    currentPlayerLives?.toString() ?? '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                onPressed: currentPlayerLives != null
                    ? () => _updateLives(currentPlayerLives! + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // PASSO 3: Mostrar Pergunta
  Widget _buildShowQuestionStep() {
    return BlocListener<PlayersBlocRP, PlayersStateRP>(
        listener: (context, state) {
          if (state is PlayerDataLoadedRP) {
            setState(() {
              currentPlayerLives = state.playerData['vidas'];
            });
          }
        },
        child: BlocListener<QuestionsBlocRP, QuestionsStateRP>(
          listener: (context, state) {
            if (state is QuestionLoadedRP) {
              setState(() {
                currentQuestion = state.question;
                // Adiciona aos recentes para evitar repetição imediata
                final questionId = state.question['id']?.toString();
                if (questionId != null) {
                  recentlyUsedQuestions.add(questionId);
                  // Limita a 10 perguntas recentes
                  if (recentlyUsedQuestions.length > 10) {
                    recentlyUsedQuestions.remove(recentlyUsedQuestions.first);
                  }
                }
              });
            } else if (state is QuestionErrorRP) {
              _showErrorSnackBar("Erro ao carregar pergunta: ${state.message}");
              setState(() {
                currentStep = GameStep.selectCategory;
              });
            }
          },
          child: BlocBuilder<QuestionsBlocRP, QuestionsStateRP>(
            builder: (context, state) {
              if (state is QuestionLoadingRP) {
                return _buildLoading("Carregando pergunta...");
              }

              if (currentQuestion == null) {
                return _buildLoading("Preparando pergunta...");
              }

              final questionText = currentQuestion!['pergunta'] ?? 'Pergunta não encontrada';
              final question = _replacePlayerPlaceholder(questionText);

              return Column(
                children: [
                  _buildPlayerInfoBar(), // barra com nome + vidas
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            question,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 100),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                          ),
                          onPressed: () {
                            // Adiciona pergunta ao histórico do jogador atual
                            final questionId = currentQuestion?['id']?.toString();
                            if (questionId != null && currentPlayerId != null) {
                              if (!playersAnsweredQuestions.containsKey(currentPlayerId!)) {
                                playersAnsweredQuestions[currentPlayerId!] = <String>{};
                              }
                              playersAnsweredQuestions[currentPlayerId!]!.add(questionId);
                            }
                            _resetGame();
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.question_answer),
                              SizedBox(width: 8),
                              Text(
                                'Responda',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15,),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 115, vertical: 12),
                          ),
                          onPressed: () {
                            // Pega desafios já completados pelo jogador atual
                            final playerChallenges = playersCompletedChallenges[currentPlayerId] ?? <String>{};

                            context.read<ChallengesBlocRP>().add(LoadChallengeRP(
                                selectedCategory!,
                                playerChallenges.toList(),
                                recentlyUsedChallenges.toList()
                            ));
                            setState(() {
                              currentStep = GameStep.showChallenge;
                            });
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department),
                              SizedBox(width: 8),
                              Text(
                                'Pague',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
    );
  }

  // PASSO 4: Mostrar Desafio
  Widget _buildShowChallengeStep() {
    return BlocListener<PlayersBlocRP, PlayersStateRP>(
        listener: (context, state) {
          if (state is PlayerDataLoadedRP) {
            setState(() {
              currentPlayerLives = state.playerData['vida'];
            });
          }
        },
        child: BlocListener<ChallengesBlocRP, ChallengesStateRP>(
          listener: (context, state) {
            if (state is ChallengeLoadedRP) {
              setState(() {
                currentChallenge = state.challenge;
                // Adiciona aos recentes
                final challengeId = state.challenge['id']?.toString();
                if (challengeId != null) {
                  recentlyUsedChallenges.add(challengeId);
                  // Limita a 10 desafios recentes
                  if (recentlyUsedChallenges.length > 10) {
                    recentlyUsedChallenges.remove(recentlyUsedChallenges.first);
                  }
                }
              });
            } else if (state is ChallengeErrorRP) {
              _showErrorSnackBar("Erro ao carregar desafio: ${state.message}");
              setState(() {
                currentStep = GameStep.showQuestion;
              });
            }
          },
          child: BlocBuilder<ChallengesBlocRP, ChallengesStateRP>(
            builder: (context, state) {
              if (state is ChallengeLoadingRP) {
                return _buildLoading("Carregando desafio...");
              }

              if (currentChallenge == null) {
                return _buildLoading("Preparando desafio...");
              }

              final challengeText = currentChallenge!['desafio'] ?? 'Desafio não encontrado';
              final challenge = _replacePlayerPlaceholder(challengeText);

              return Column(
                children: [
                  _buildPlayerInfoBar(), // barra com nome + vidas
                  const SizedBox(height: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                challenge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 12),
                          ),
                          onPressed: () {
                            // Adiciona desafio ao histórico do jogador atual
                            final challengeId = currentChallenge?['id']?.toString();
                            if (challengeId != null && currentPlayerId != null) {
                              if (!playersCompletedChallenges.containsKey(currentPlayerId!)) {
                                playersCompletedChallenges[currentPlayerId!] = <String>{};
                              }
                              playersCompletedChallenges[currentPlayerId!]!.add(challengeId);
                            }
                            _resetGame();
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_forward),
                              SizedBox(width: 8),
                              Text(
                                'Próximo Jogador',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
    );
  }

  Widget _buildLoading(String message) {
    return Column(
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
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getCategoryDisplayName(String? category) {
    switch (category) {
      case 'moderado':
        return 'Moderado';
      case 'picante':
        return 'Picante';
      case 'aleatorio':
        return 'Aleatório';
      default:
        return 'Desconhecida';
    }
  }
}