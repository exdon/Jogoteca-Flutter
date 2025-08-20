import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/players/players_bloc.dart';
import 'package:jogoteca/blocs/players/players_event.dart';
import 'package:jogoteca/blocs/players/players_state.dart';
import 'package:jogoteca/blocs/questions/questions_bloc.dart';
import 'package:jogoteca/blocs/questions/questions_state.dart';
import 'package:jogoteca/screens/prazer_anonimo/form_controllers.dart';
import 'package:jogoteca/screens/prazer_anonimo/game/dialog_helper.dart';
import 'package:jogoteca/screens/prazer_anonimo/game/game_state_manager.dart';
import 'package:jogoteca/screens/prazer_anonimo/game/game_widgets.dart';
import 'package:jogoteca/screens/prazer_anonimo/round_manager.dart';
import 'package:jogoteca/widget/app_bar_game.dart';

class GameScreen extends StatefulWidget {
  final String partidaId;

  const GameScreen({super.key, required this.partidaId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int indice = 0;
  bool pinValidado = false;
  bool _isProcessing = false;
  bool _isDisposed = false;
  bool hasDirectMessages = false;
  List<Map<String, dynamic>> _players = [];
  String? _directsLoadedFor;
  bool _showDrinkingInterface = false;
  int _drinkingCount = 0;
  int _minDrinkingCount = 0;
  List<String> _sortedDrinkingPlayers = [];
  bool _hasDrawnPlayers = false;

  String? currentQuestionId;
  String? currentQuestion;
  List<Map<String, dynamic>> directMessages = [];
  List<Map<String, dynamic>> superAnonimoQuestions = [];

  // Managers e controllers
  late final RoundManager _roundManager;
  late final FormControllers _formControllers;

  @override
  void initState() {
    super.initState();
    GameStateManager.initializeGame(widget.partidaId);
    _roundManager = RoundManager();
    _formControllers = FormControllers();
    _formControllers.setStateChangeCallback(() => setState(() {}));
  }

  @override
  void dispose() {
    _isDisposed = true;
    _formControllers.dispose();
    super.dispose();
  }

  void _setJogadorDaVez(int novoIndice) {
    setState(() {
      indice = novoIndice;
      hasDirectMessages = false;
      directMessages = [];
      _directsLoadedFor = null;
    });

    if (_players.isNotEmpty && indice < _players.length) {
      final jogadorAtualId = _players[indice]['id'];
      _directsLoadedFor = jogadorAtualId;
      context.read<PlayersBloc>().add(
        LoadDirectMessages(widget.partidaId, jogadorAtualId),
      );
    }
  }

  void _getNewQuestion(String jogadorId, List<Map<String, dynamic>> perguntas, List<Map<String, dynamic>> players) {
    if (_isDisposed) return;

    // Se já temos uma pergunta para este jogador na rodada atual, não muda
    if (currentQuestionId != null && currentQuestion != null) {
      return;
    }

    final questionData = GameStateManager.getNewQuestionForPlayer(widget.partidaId, jogadorId, perguntas, players);

    if (questionData == null) {
      currentQuestionId = null;
      currentQuestion = null;
    } else {
      currentQuestionId = questionData['id'];
      currentQuestion = questionData['pergunta'];
    }
  }

  void _prepareNewRound(List<Map<String, dynamic>> players, List<Map<String, dynamic>> perguntas) {
    // Use addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed || !mounted) return;

      _roundManager.prepareNewRound(widget.partidaId, players, perguntas);

      setState(() {
        currentQuestionId = null;
        currentQuestion = null;
      });

      if (_roundManager.hasEligiblePlayers) {
        _setJogadorDaVez(_roundManager.eligiblePlayerIndices[0]);
      }
    });
  }

  void _startNewRound(List<Map<String, dynamic>> players, List<Map<String, dynamic>> perguntas) {
    _roundManager.startNewRound();
    setState(() {
      pinValidado = false;
      hasDirectMessages = false;
      directMessages = [];
    });
    _formControllers.pinController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      _prepareNewRound(players, perguntas);
    });
  }

  void _checkPin(BuildContext dialogContext, String jogadorId, String pinCorreto, List<Map<String, dynamic>> perguntas, List<Map<String, dynamic>> players) async {
    if (_isDisposed || _isProcessing) return;

    if (_formControllers.pinController.text.trim() == pinCorreto) {
      setState(() {
        _isProcessing = true;
      });

      final playersBloc = context.read<PlayersBloc>();
      if (!playersBloc.isClosed) {
        setState(() {
          hasDirectMessages = false;
          directMessages = [];
        });
        playersBloc.add(LoadDirectMessages(widget.partidaId, jogadorId));
      }

      await Future.delayed(const Duration(milliseconds: 250));
      if (mounted) {
        Navigator.of(dialogContext).pop();
        setState(() {
          pinValidado = true;
          _isProcessing = false;
        });
        _getNewQuestion(jogadorId, perguntas, players);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PIN inválido")),
        );
      }
    }
  }

  void _salvarResposta(String jogadorId, List<Map<String, dynamic>> players) {
    if (_isDisposed || _isProcessing || !mounted) return;
    if (currentQuestionId == null) return;

    // Valida os campos antes de prosseguir
    if (!_formControllers.validateFields(context)) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      GameStateManager.markQuestionAnswered(widget.partidaId, jogadorId, currentQuestionId!);

      final answer = _formControllers.getAnswer();
      final perguntaSuperAnonimo = _formControllers.getPerguntaSuperAnonimo();
      final superAnonimoAnswer = _formControllers.getSuperAnonimoAnswer();
      final mensagemDirect = _formControllers.getMensagemDirect();

      // Verifica se é o primeiro a escolher super anônimo nesta rodada
      bool isSuperAnonimoValid = _formControllers.superAnonimoActive &&
          GameStateManager.setSuperAnonimoPlayer(widget.partidaId, jogadorId);

      final playersBloc = context.read<PlayersBloc>();
      if (!playersBloc.isClosed) {
        playersBloc.add(
          AddPlayerData(
            widget.partidaId,
            jogadorId,
            currentQuestion!,
            answer,
            isSuperAnonimoValid && _formControllers.superAnonimoMode == 'toResults', // mantém no resultado apenas se for 'toResults'
            (isSuperAnonimoValid && _formControllers.superAnonimoMode == 'toResults') ? perguntaSuperAnonimo : null,
            (isSuperAnonimoValid && _formControllers.superAnonimoMode == 'toResults') ? superAnonimoAnswer : null,
          ),
        );

        // Se for Super Anônimo "para jogador", envia a pergunta sem resposta ao destinatário
        if (_formControllers.superAnonimoActive &&
            _formControllers.superAnonimoMode == 'toPlayer') {
          final destinatarioId = _formControllers.getSelectedSuperAnonimoPlayer()!;
          final perguntaParaJogador = _formControllers.getPerguntaParaJogador();
          final remetenteNome = _players.firstWhere((p) => p['id'] == jogadorId)['nome'];
          playersBloc.add(
            SendSuperAnonimoQuestion(
              widget.partidaId,
              jogadorId,
              destinatarioId,
              perguntaParaJogador,
            ),
          );
        }

        if (_formControllers.selectedDirectPlayer != null && mensagemDirect.isNotEmpty) {
          playersBloc.add(
            SendDirectMessage(
              widget.partidaId,
              jogadorId,
              _formControllers.selectedDirectPlayer!,
              mensagemDirect,
            ),
          );
        }
      }

      // Se o jogador atual tem perguntas de SA pendentes, responder todas aqui (obrigatórias)
      if (superAnonimoQuestions.isNotEmpty) {
        final saAnswers = _formControllers.getSAInboxAnswers();
        for (final q in superAnonimoQuestions) {
          final qid = q['id'] as String;
          final perguntaSA = q['pergunta']?.toString() ?? '';
          final respostaSA = saAnswers[qid]?.trim() ?? '';
          if (respostaSA.isNotEmpty) {
            // Atualiza backend marcando como respondida
            if (!playersBloc.isClosed) {
              playersBloc.add(
                AnswerSuperAnonimoQuestion(
                  widget.partidaId,
                  jogadorId,
                  qid,
                  respostaSA,
                ),
              );
            }
            // Adiciona no resultado da rodada como "pergunta + resposta do jogador escolhido"
            final jogadorNomeAtual = _players.firstWhere((p) => p['id'] == jogadorId)['nome'];
            _roundManager.addRoundResult({
              'jogadorId': jogadorId,
              'jogadorNome': jogadorNomeAtual,
              'pergunta': perguntaSA,
              'resposta': respostaSA,
            });
          }
        }
      }

      final jogadorNome = players.firstWhere((p) => p['id'] == jogadorId)['nome'];
      _roundManager.addRoundResult({
        'jogadorId': jogadorId,
        'jogadorNome': jogadorNome,
        'pergunta': currentQuestion!,
        'resposta': answer,
      });

      // Adiciona resultado do super anônimo se válido
      if (isSuperAnonimoValid) {
        _roundManager.addSuperAnonimoResult(perguntaSuperAnonimo, superAnonimoAnswer);
      }

      _roundManager.markPlayerAnswered(jogadorId);
      _formControllers.resetAllFields();

      if (_roundManager.isRoundComplete) {
        final questionsBloc = context.read<QuestionsBloc>();
        if (questionsBloc.state is QuestionsLoaded) {
          final perguntas = (questionsBloc.state as QuestionsLoaded).questions;
          final iaAnonimoData = GameStateManager.getIAnonimoQuestionAnswer(widget.partidaId, perguntas);
          if (iaAnonimoData != null) {
            _roundManager.addRoundResult({
              'jogadorId': 'ianonimo',
              'jogadorNome': 'IA Anônimo',
              'pergunta': iaAnonimoData['pergunta']!,
              'resposta': iaAnonimoData['resposta']!,
            });
          }
        }

        setState(() {
          _roundManager.finishRound();
          _isProcessing = false;
          currentQuestionId = null;
          currentQuestion = null;
          pinValidado = false;
          hasDirectMessages = false;
          directMessages = [];
        });
      } else {
        _roundManager.moveToNextPlayer();
        final nextIndex = _roundManager.eligiblePlayerIndices[_roundManager.eligiblePointer];
        _setJogadorDaVez(nextIndex);

        setState(() {
          pinValidado = false;
          _isProcessing = false;
          currentQuestionId = null;
          currentQuestion = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar resposta: $e")),
        );
      }
    }
  }

  void _showDirectMessagesDialog(String jogadorId) {
    DialogHelper.showDirectMessagesDialog(
        context: context,
        directMessages: directMessages,
        playerId: jogadorId,
        onReadMessage: _showReadMessageDialog,
        onReadAgainMessage: _showReadMessageAgainDialog
    );
  }

  void _showReadMessageDialog(Map<String, dynamic> message, String jogadorId, void Function(void Function())? setStateDialog) {
    DialogHelper.showReadMessageDialog(
      context: context,
      message: message,
      playerId: jogadorId,
      partidaId: widget.partidaId,
      directMessages: directMessages,
      setStateDialog: setStateDialog,
      onUpdateMainState: () {
        setState(() {});
      },
    );
  }

  void _showReadMessageAgainDialog(Map<String, dynamic> message) {
    DialogHelper.showReadMessageAgainDialog(
      context: context,
      message: message,
    );
  }

  void _showPinDialog(String id, String pinCorreto, List<Map<String, dynamic>> perguntas, List<Map<String, dynamic>> players) {
    DialogHelper.showPinDialog(
      context: context,
      pinController: _formControllers.pinController,
      playerId: id,
      correctPin: pinCorreto,
      questions: perguntas,
      players: players,
      isProcessing: _isProcessing,
      onCheckPin: _checkPin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarGame(disablePartida: true, deletePartida: false, partidaId: widget.partidaId),
      body: BlocListener<PlayersBloc, PlayersState>(
        listener: (context, state) {
          if ((state is PlayersLoadedWithMessages || state is PlayersLoadedWithMessagesAndSA) &&
              _players.isNotEmpty &&
              indice < _players.length) {

            final jogadorAtualId = _players[indice]['id'];

            if (_directsLoadedFor != jogadorAtualId) {
              return;
            }

            final List<Map<String, dynamic>> mensagens = state is PlayersLoadedWithMessagesAndSA
                ? state.directMessages
                : (state as PlayersLoadedWithMessages).directMessages;

            final unread = mensagens
                .where((m) => m['lida'] == false && m['remetenteId'] != jogadorAtualId)
                .toList();

            setState(() {
              hasDirectMessages = unread.isNotEmpty;
              directMessages = unread;
              // SA questions pendentes (somente no novo estado)
              if (state is PlayersLoadedWithMessagesAndSA) {
                superAnonimoQuestions = state.superAnonimoQuestions;
              } else {
                superAnonimoQuestions = [];
              }
            });

            // Atualiza controllers com as SA pendentes
            _formControllers.setPendingSAQuestions(superAnonimoQuestions);
          }
        },
        child: Stack(
          children: [
            // Fundo
            Positioned.fill(
              child: Image.asset("images/background_anonimo.jpg", fit: BoxFit.cover),
            ),
            // Overlay escuro
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: BlocBuilder<PlayersBloc, PlayersState>(
                builder: (context, playersState) {
                  if (playersState is PlayersLoaded ||
                      playersState is PlayersLoadedWithMessages ||
                      playersState is PlayersLoadedWithMessagesAndSA) {

                    final currentPlayers =
                    playersState is PlayersLoaded
                        ? playersState.players
                        : playersState is PlayersLoadedWithMessages
                        ? playersState.players
                        : (playersState as PlayersLoadedWithMessagesAndSA).players;

                    _players = List<Map<String, dynamic>>.from(currentPlayers);
                    // Ordena pelo campo 'indice' (crescente)
                    _players.sort((a, b) => (a['indice'] as int).compareTo(b['indice'] as int));

                    return BlocBuilder<QuestionsBloc, QuestionsState>(
                      builder: (context, questionsState) {
                        if (questionsState is QuestionsLoaded) {
                          return _buildGameContent(questionsState.questions);
                        } else if (questionsState is QuestionsLoading || questionsState is QuestionsInitial) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (questionsState is QuestionsError) {
                          return Center(child: Text("Erro ao carregar perguntas: ${questionsState.message}", style: TextStyle(color: Colors.white)));
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    );
                  } else if (playersState is PlayersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (playersState is PlayersError) {
                    return Center(child: Text("Erro ao carregar jogadores: ${playersState.message}", style: TextStyle(color: Colors.white)));
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameContent(List<Map<String, dynamic>> perguntas) {
    // MUDANÇA PRINCIPAL: Verificar se a rodada precisa ser preparada sem chamar setState diretamente
    if (!_roundManager.roundPrepared) {
      // Use addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isDisposed || !mounted) return;
        _prepareNewRound(_players, perguntas);
      });

      // Retorna um loading enquanto prepara a rodada
      return const Center(child: CircularProgressIndicator());
    }

    if (_roundManager.gameOver) {
      return GameWidgets.buildGameOverScreen(
        onNewGame: () {
          setState(() {
            GameStateManager.removeGame(widget.partidaId);
            _roundManager.resetGame();
          });
        },
      );
    }

    if (_roundManager.showRoundResults && !_showDrinkingInterface) {
      return GameWidgets.buildRoundResults(
        roundResults: _roundManager.roundResults,
        onContinue: () {
          final noCount = _roundManager.countNoResponses(_roundManager.roundResults);
          setState(() {
            _showDrinkingInterface = true;
            _drinkingCount = noCount;
            _minDrinkingCount = noCount;
            _hasDrawnPlayers = false;
            _sortedDrinkingPlayers = [];
          });
        },
      );
    }

    if (_roundManager.showRoundResults && _showDrinkingInterface) {
      return GameWidgets.buildDrinkingInterface(
        noResponseCount: _minDrinkingCount,
        drinkingCount: _drinkingCount,
        onIncrease: () {
          setState(() {
            _drinkingCount++;
          });
        },
        onDecrease: () {
          if (_drinkingCount > _minDrinkingCount) {
            setState(() {
              _drinkingCount--;
            });
          }
        },
        onDrawPlayers: () {
          final drawnPlayers = _roundManager.drawRandomPlayers(_players, _drinkingCount);
          setState(() {
            _sortedDrinkingPlayers = drawnPlayers;
            _hasDrawnPlayers = true;
          });
        },
        sortedPlayers: _sortedDrinkingPlayers,
        hasDrawnPlayers: _hasDrawnPlayers,
        onNewRound: () {
          setState(() {
            _showDrinkingInterface = false;
            _hasDrawnPlayers = false;
            _sortedDrinkingPlayers = [];
            _drinkingCount = 0;
            _minDrinkingCount = 0;
          });
          final allDone = _roundManager.checkGameOver(widget.partidaId, perguntas, _players);
          if (allDone) {
            setState(() {});
          } else {
            _startNewRound(_players, perguntas);
          }
        },
      );
    }

    if (!_roundManager.hasEligiblePlayers) {
      return const Center(child: Text("Nenhuma pergunta disponível no momento", style: TextStyle(color: Colors.white)));
    }

    if (!_roundManager.eligiblePlayerIndices.contains(indice)) {
      // Use addPostFrameCallback para mudanças de estado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isDisposed || !mounted) return;

        if (_roundManager.eligiblePointer < _roundManager.eligiblePlayerIndices.length) {
          _setJogadorDaVez(_roundManager.eligiblePlayerIndices[_roundManager.eligiblePointer]);
        } else {
          _roundManager.eligiblePointer = 0;
          _setJogadorDaVez(_roundManager.eligiblePlayerIndices[0]);
        }
      });

      return const Center(child: CircularProgressIndicator());
    }

    final jogador = _players[indice];
    final nome = jogador['nome'];
    final id = jogador['id'];
    final pinCorreto = jogador['pin'].toString();

    // ← AQUI você garante que o formControllers conhece as SA pendentes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _formControllers.setPendingSAQuestions(superAnonimoQuestions);
      }
    });
    _getNewQuestion(id, perguntas, _players);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameWidgets.buildPlayerHeader(
            playerName: nome,
            hasDirectMessages: hasDirectMessages,
            pinValidated: pinValidado,
            onDirectMessagesPressed: () => _showDirectMessagesDialog(id),
          ),
          const SizedBox(height: 50),
          if (!pinValidado) ...[
            GameWidgets.buildValidatePinButton(
              isProcessing: _isProcessing,
              onPressed: () => _showPinDialog(id, pinCorreto, perguntas, _players),
            ),
          ] else ...[
            if (currentQuestionId == null) ...[
              GameWidgets.buildNoQuestionsAvailable(
                onNextPlayer: () {
                  if (_roundManager.eligiblePointer + 1 < _roundManager.eligiblePlayerIndices.length) {
                    _roundManager.moveToNextPlayer();
                    _setJogadorDaVez(_roundManager.eligiblePlayerIndices[_roundManager.eligiblePointer]);
                    setState(() {
                      pinValidado = false;
                      currentQuestionId = null;
                      currentQuestion = null;
                    });
                  } else {
                    setState(() {
                      _roundManager.showRoundResults = true;
                    });
                  }
                },
              ),
            ],
            if (currentQuestionId != null) ...[
              Expanded(
                child: GameWidgets.buildQuestionForm(
                  question: currentQuestion!,
                  formControllers: _formControllers,
                  isProcessing: _isProcessing,
                  players: _players,
                  currentPlayerId: id,
                  saQuestions: superAnonimoQuestions,
                ),
              ),
              GameWidgets.buildSaveButton(
                isProcessing: _isProcessing,
                onPressed: () => _salvarResposta(id, _players),
              ),
            ],
          ],
        ],
      ),
    );
  }
}