import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/prazer_anonimo/players/players_bloc_pa.dart';
import 'package:jogoteca/blocs/prazer_anonimo/players/players_event_pa.dart';
import 'package:jogoteca/blocs/prazer_anonimo/players/players_state_pa.dart';
import 'package:jogoteca/blocs/prazer_anonimo/questions/questions_bloc_pa.dart';
import 'package:jogoteca/blocs/prazer_anonimo/questions/questions_state_pa.dart';
import 'package:jogoteca/constants/prazer_anonimo/prazer_anonimo_constants.dart';
import 'package:jogoteca/guards/game_pop_guard.dart';
import 'package:jogoteca/screens/prazer_anonimo/form_controllers_pa.dart';
import 'package:jogoteca/screens/prazer_anonimo/game/dialog_helper.dart';
import 'package:jogoteca/screens/prazer_anonimo/game/game_state_manager_pa.dart';
import 'package:jogoteca/screens/prazer_anonimo/game/game_pa_widgets.dart';
import 'package:jogoteca/screens/prazer_anonimo/round_manager_pa.dart';
import 'package:jogoteca/widget/app_bar_game.dart';

class PrazerAnonimoGameScreen extends StatefulWidget {
  final String partidaId;

  const PrazerAnonimoGameScreen({super.key, required this.partidaId});

  @override
  State<PrazerAnonimoGameScreen> createState() => _PrazerAnonimoGameScreenState();
}

class _PrazerAnonimoGameScreenState extends State<PrazerAnonimoGameScreen> {
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
  late final RoundManagerPA _roundManager;
  late final FormControllersPA _formControllers;

  @override
  void initState() {
    super.initState();
    GameStateManagerPA.initializeGame(widget.partidaId);
    _roundManager = RoundManagerPA();
    _formControllers = FormControllersPA();
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
      context.read<PlayersBlocPA>().add(
        LoadDirectMessagesPA(widget.partidaId, jogadorAtualId),
      );
    }
  }

  void _getNewQuestion(String jogadorId, List<Map<String, dynamic>> perguntas, List<Map<String, dynamic>> players) {
    if (_isDisposed) return;

    // Se já temos uma pergunta para este jogador na rodada atual, não muda
    if (currentQuestionId != null && currentQuestion != null) {
      return;
    }

    final questionData = GameStateManagerPA.getNewQuestionForPlayer(widget.partidaId, jogadorId, perguntas, players);

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

      final playersBloc = context.read<PlayersBlocPA>();
      if (!playersBloc.isClosed) {
        setState(() {
          hasDirectMessages = false;
          directMessages = [];
        });
        playersBloc.add(LoadDirectMessagesPA(widget.partidaId, jogadorId));
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
      GameStateManagerPA.markQuestionAnswered(widget.partidaId, jogadorId, currentQuestionId!);

      final answer = _formControllers.getAnswer();
      final perguntaSuperAnonimo = _formControllers.getPerguntaSuperAnonimo();
      final superAnonimoAnswer = _formControllers.getSuperAnonimoAnswer();
      final mensagemDirect = _formControllers.getMensagemDirect();
      bool shouldAddToResults = false;
      String? detalhesSuperAnonimo;

      // Verifica se é o primeiro a escolher super anônimo nesta rodada
      bool isSuperAnonimoValid = _formControllers.superAnonimoActive;

      if (isSuperAnonimoValid && _formControllers.superAnonimoMode == 'toResults') {
        shouldAddToResults = GameStateManagerPA.setSuperAnonimoPlayer(widget.partidaId, jogadorId);
        isSuperAnonimoValid = shouldAddToResults;
      } else if (isSuperAnonimoValid && (_formControllers.superAnonimoMode == 'toPlayer' || _formControllers.superAnonimoMode == 'toChallenge')) {
        shouldAddToResults = true;

        // Define detalhes para os modos jogador e desafio
        if (_formControllers.superAnonimoMode == 'toPlayer') {
          final destinatario = _players.firstWhere((p) => p['id'] == _formControllers.getSelectedSuperAnonimoPlayer());
          detalhesSuperAnonimo = 'enviou pergunta para jogador ${destinatario['nome']}';
        } else if (_formControllers.superAnonimoMode == 'toChallenge') {
          if (_formControllers.challengeTarget == 'all') {
            detalhesSuperAnonimo = 'enviou desafio para todos os jogadores';
          } else if (_formControllers.challengeTarget == 'one') {
            final player1 = _players.firstWhere((p) => p['id'] == _formControllers.getSelectedChallengePlayer1());
            detalhesSuperAnonimo = 'enviou desafio para jogador ${player1['nome']}';
          } else {
            final player1 = _players.firstWhere((p) => p['id'] == _formControllers.getSelectedChallengePlayer1());
            final player2 = _players.firstWhere((p) => p['id'] == _formControllers.getSelectedChallengePlayer2());
            detalhesSuperAnonimo = 'enviou desafio para jogadores ${player1['nome']} e ${player2['nome']}';
          }
        }
      }

      final playersBloc = context.read<PlayersBlocPA>();
      if (!playersBloc.isClosed) {
        playersBloc.add(
          AddPlayerDataPA(
            widget.partidaId,
            jogadorId,
            currentQuestion!,
            answer,
            isSuperAnonimoValid,
            (isSuperAnonimoValid && _formControllers.superAnonimoMode == 'toResults') ? perguntaSuperAnonimo : null,
            (isSuperAnonimoValid && _formControllers.superAnonimoMode == 'toResults') ? superAnonimoAnswer : null,
            detalhesSuperAnonimo,
          ),
        );

        // Lógica para cada modo do Super Anônimo
        if (_formControllers.superAnonimoActive) {
          if (_formControllers.superAnonimoMode == 'toPlayer') {
            final destinatarioId = _formControllers.getSelectedSuperAnonimoPlayer()!;
            final perguntaParaJogador = _formControllers.getPerguntaParaJogador();
            playersBloc.add(
              SendSuperAnonimoQuestionPA(
                widget.partidaId,
                jogadorId,
                destinatarioId,
                perguntaParaJogador,
              ),
            );
          } else if (_formControllers.superAnonimoMode == 'toChallenge') {
            final desafio = _formControllers.getDesafio();

            // Enviar desafio para jogadores
            if (_formControllers.challengeTarget == 'all') {
              for (final player in _players) {
                if (player['id'] != jogadorId) {
                  playersBloc.add(
                    SendSuperAnonimoChallengePA(
                      widget.partidaId,
                      jogadorId,
                      player['id'],
                      desafio,
                      'Todos'
                    ),
                  );
                }
              }

              // Adiciona card de desafio nos resultados da rodada
              _roundManager.addRoundResult({
                'jogadorId': 'desafio',
                'jogadorNome': 'Desafio para: Todos',
                'pergunta': '',
                'resposta': desafio,
                'tipo': 'challenge',
                'isChallenge': true,
              });
            } else if (_formControllers.challengeTarget == 'one') {
              final destId = _formControllers.getSelectedChallengePlayer1()!;
              final destName = _players.firstWhere((p) => p['id'] == destId)['nome'];

              playersBloc.add(
                SendSuperAnonimoChallengePA(
                  widget.partidaId,
                  jogadorId,
                  _formControllers.getSelectedChallengePlayer1()!,
                  desafio,
                  destName
                ),
              );

              // Adiciona card de desafio nos resultados da rodada
              _roundManager.addRoundResult({
                'jogadorId': 'desafio',
                'jogadorNome': 'Desafio para: $destName',
                'pergunta': '',
                'resposta': desafio,
                'tipo': 'challenge',
                'isChallenge': true,
              });
            } else {
              final dest1Id = _formControllers.getSelectedChallengePlayer1()!;
              final dest1Name = _players.firstWhere((p) => p['id'] == dest1Id)['nome'];

              final dest2Id = _formControllers.getSelectedChallengePlayer2()!;
              final dest2Name = _players.firstWhere((p) => p['id'] == dest2Id)['nome'];

              // Cria um único card com os dois nomes
              final nomesCombinados = '$dest1Name e $dest2Name';

              // Envia desafio para o primeiro jogador
              playersBloc.add(
                SendSuperAnonimoChallengePA(
                  widget.partidaId,
                  jogadorId,
                  dest1Id,
                  desafio,
                  nomesCombinados
                ),
              );


              // Envia desafio para o segundo jogador
              playersBloc.add(
                SendSuperAnonimoChallengePA(
                  widget.partidaId,
                  jogadorId,
                  dest2Id,
                  desafio,
                  nomesCombinados
                ),
              );

              _roundManager.addRoundResult({
                'jogadorId': 'desafio',
                'jogadorNome': 'Desafio para: $nomesCombinados',
                'pergunta': '',
                'resposta': desafio,
                'tipo': 'challenge',
                'isChallenge': true,
              });
            }
          }
        }

        if (_formControllers.selectedDirectPlayer != null && mensagemDirect.isNotEmpty) {
          playersBloc.add(
            SendDirectMessagePA(
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
                AnswerSuperAnonimoQuestionPA(
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

      // Adiciona resultado do super anônimo apenas no modo 'toResults'
      if (isSuperAnonimoValid && _formControllers.superAnonimoMode == 'toResults') {
        _roundManager.addSuperAnonimoResult(perguntaSuperAnonimo, superAnonimoAnswer);
      }

      _roundManager.markPlayerAnswered(jogadorId);
      _formControllers.resetAllFields();

      if (_roundManager.isRoundComplete) {
        final questionsBloc = context.read<QuestionsBlocPA>();
        if (questionsBloc.state is QuestionsLoadedPA) {
          final perguntas = (questionsBloc.state as QuestionsLoadedPA).questions;
          final iaAnonimoData = GameStateManagerPA.getIAnonimoQuestionAnswer(widget.partidaId, perguntas);
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
    return GamePopGuard(
      partidaId: widget.partidaId,
      gameId: PrazerAnonimoConstants.gameId,
      database: PrazerAnonimoConstants.dbPartidas,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBarGame(
          disablePartida: true,
          deletePartida: false,
          partidaId: widget.partidaId,
          gameId: PrazerAnonimoConstants.gameId,
          database: PrazerAnonimoConstants.dbPartidas,
        ),
        body: BlocListener<PlayersBlocPA, PlayersStatePA>(
          listener: (context, state) {
            if ((state is PlayersLoadedWithMessagesPA || state is PlayersLoadedWithMessagesAndSA) &&
                _players.isNotEmpty &&
                indice < _players.length) {

              final jogadorAtualId = _players[indice]['id'];

              if (_directsLoadedFor != jogadorAtualId) {
                return;
              }

              final List<Map<String, dynamic>> mensagens = state is PlayersLoadedWithMessagesAndSA
                  ? state.directMessages
                  : (state as PlayersLoadedWithMessagesPA).directMessages;

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
                child: BlocBuilder<PlayersBlocPA, PlayersStatePA>(
                  builder: (context, playersState) {
                    if (playersState is PlayersLoadedPA ||
                        playersState is PlayersLoadedWithMessagesPA ||
                        playersState is PlayersLoadedWithMessagesAndSA) {

                      final currentPlayers =
                      playersState is PlayersLoadedPA
                          ? playersState.players
                          : playersState is PlayersLoadedWithMessagesPA
                          ? playersState.players
                          : (playersState as PlayersLoadedWithMessagesAndSA).players;

                      _players = List<Map<String, dynamic>>.from(currentPlayers);
                      // Ordena pelo campo 'indice' (crescente)
                      _players.sort((a, b) => (a['indice'] as int).compareTo(b['indice'] as int));

                      return BlocBuilder<QuestionsBlocPA, QuestionsStatePA>(
                        builder: (context, questionsState) {
                          if (questionsState is QuestionsLoadedPA) {
                            return _buildGameContent(questionsState.questions);
                          } else if (questionsState is QuestionsLoadingPA || questionsState is QuestionsInitialPA) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (questionsState is QuestionsErrorPA) {
                            return Center(child: Text("Erro ao carregar perguntas: ${questionsState.message}", style: TextStyle(color: Colors.white)));
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      );
                    } else if (playersState is PlayersLoadingPA) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (playersState is PlayersErrorPA) {
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
            GameStateManagerPA.removeGame(widget.partidaId);
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
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

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
              if (!isKeyboardOpen)
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