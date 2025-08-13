import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/players/players_bloc.dart';
import '../../blocs/players/players_event.dart';
import '../../blocs/players/players_state.dart';
import '../../blocs/questions/questions_bloc.dart';
import '../../blocs/questions/questions_state.dart';
import '../../widget/app_bar_game.dart';

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

  final _pinController = TextEditingController();
  final _respostaController = TextEditingController();
  final _perguntaSuperAnonimoController = TextEditingController();
  final _respostaSuperAnonimoController = TextEditingController();
  final _mensagemDirectController = TextEditingController();

  bool chooseNo = false;
  bool superAnonimoActive = false;
  bool directActive = false;
  String? selectedDirectPlayer;
  static final Map<String, Map<String, Set<String>>> gameAnsweredQuestions = {};
  static final Map<String, String> gameSuperAnonimoPlayer = {}; // Controla quem é o super anônimo da rodada
  String? currentQuestionId;
  String? currentQuestion;
  List<Map<String, dynamic>> directMessages = [];

  List<Map<String, dynamic>> roundResults = [];
  List<int> eligiblePlayerIndices = [];
  int eligiblePointer = 0;
  Set<String> playersAnsweredThisRound = {};
  bool showRoundResults = false;
  bool gameOver = false;
  bool _roundPrepared = false;

  @override
  void initState() {
    super.initState();
    if (!gameAnsweredQuestions.containsKey(widget.partidaId)) {
      gameAnsweredQuestions[widget.partidaId] = {};
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pinController.dispose();
    _respostaController.dispose();
    _perguntaSuperAnonimoController.dispose();
    _respostaSuperAnonimoController.dispose();
    _mensagemDirectController.dispose();
    super.dispose();
  }

  void _resetSuperAnonimoFields() {
    _perguntaSuperAnonimoController.clear();
    _respostaSuperAnonimoController.clear();
  }

  void _resetDirectFields() {
    _mensagemDirectController.clear();
    selectedDirectPlayer = null;
  }

  bool questionAnsweredByEverybody(String perguntaId, List<Map<String, dynamic>> players) {
    for (final player in players) {
      final answered = gameAnsweredQuestions[widget.partidaId]?[player['id']] ?? {};
      if (!answered.contains(perguntaId)) {
        return false;
      }
    }
    return true;
  }

  bool allQuestionsAnsweredByEverybody(List<Map<String, dynamic>> perguntas, List<Map<String, dynamic>> players) {
    for (final pergunta in perguntas) {
      if (!questionAnsweredByEverybody(pergunta['id'], players)) {
        return false;
      }
    }
    return true;
  }

  bool _hasAvailableQuestionForPlayer(String jogadorId, List<Map<String, dynamic>> perguntas, List<Map<String, dynamic>> players) {
    final partidaAnswers = gameAnsweredQuestions[widget.partidaId] ?? {};
    final answeredByThisPlayer = partidaAnswers[jogadorId] ?? {};

    for (final p in perguntas) {
      final pid = p['id'];
      if (answeredByThisPlayer.contains(pid)) continue;
      if (questionAnsweredByEverybody(pid, players)) continue;
      return true;
    }
    return false;
  }

  void _getNewQuestion(String jogadorId, List<Map<String, dynamic>> perguntas, List<Map<String, dynamic>> players) {
    if (_isDisposed) return;

    // Se já temos uma pergunta para este jogador na rodada atual, não muda
    if (currentQuestionId != null && currentQuestion != null) {
      return;
    }

    final partidaAnswers = gameAnsweredQuestions[widget.partidaId] ?? {};
    final answered = partidaAnswers[jogadorId] ?? {};
    final questionsDisponiveis = perguntas.where((p) {
      final pid = p['id'];
      if (answered.contains(pid)) return false;
      if (questionAnsweredByEverybody(pid, players)) return false;
      return true;
    }).toList();

    if (questionsDisponiveis.isEmpty) {
      currentQuestionId = null;
      currentQuestion = null;
    } else {
      questionsDisponiveis.shuffle();
      currentQuestionId = questionsDisponiveis.first['id'];
      currentQuestion = questionsDisponiveis.first['pergunta'];
    }
  }

  void _prepareNewRound(List<Map<String, dynamic>> players, List<Map<String, dynamic>> perguntas) {
    // Reset do super anônimo para nova rodada
    gameSuperAnonimoPlayer.remove(widget.partidaId);

    final localEligible = <int>[];
    for (var i = 0; i < players.length; i++) {
      final pid = players[i]['id'];
      if (_hasAvailableQuestionForPlayer(pid, perguntas, players)) {
        localEligible.add(i);
      }
    }

    if (localEligible.isEmpty) {
      setState(() {
        _roundPrepared = true;
        eligiblePlayerIndices = [];
        eligiblePointer = 0;
        roundResults.clear();
        playersAnsweredThisRound.clear();
        showRoundResults = false;
        currentQuestionId = null;
        currentQuestion = null;
      });
      return;
    }

    setState(() {
      eligiblePlayerIndices = localEligible;
      eligiblePointer = 0;
      roundResults.clear();
      playersAnsweredThisRound.clear();
      showRoundResults = false;
      gameOver = false;
      _roundPrepared = true;
      currentQuestionId = null;
      currentQuestion = null;
    });
    _setJogadorDaVez(eligiblePlayerIndices[0]);
  }

  void _startNewRound(List<Map<String, dynamic>> players, List<Map<String, dynamic>> perguntas) {
    _roundPrepared = false;
    pinValidado = false;
    hasDirectMessages = false;
    directMessages = [];
    _pinController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      _prepareNewRound(players, perguntas);
    });
  }

  void _checkPin(BuildContext dialogContext, String jogadorId, String pinCorreto, List<Map<String, dynamic>> perguntas, List<Map<String, dynamic>> players) async {
    if (_isDisposed || _isProcessing) return;
    if (_pinController.text.trim() == pinCorreto) {
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

  bool _validateFields() {
    // Verifica se tem resposta ou escolheu "Não"
    bool hasAnswer = _respostaController.text.trim().isNotEmpty || chooseNo;
    if (!hasAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite uma resposta ou selecione 'Não'")),
      );
      return false;
    }

    // Se super anônimo está ativo, verifica os campos
    if (superAnonimoActive) {
      if (_perguntaSuperAnonimoController.text.trim().isEmpty ||
          _respostaSuperAnonimoController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Preencha todos os campos do Super Anônimo ou desabilite a opção")),
        );
        return false;
      }
    }

    // Se direct está ativo, verifica os campos
    if (directActive) {
      if (selectedDirectPlayer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Selecione um jogador para enviar a mensagem ou desabilite o Direct")),
        );
        return false;
      }
      if (selectedDirectPlayer != null && _mensagemDirectController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Digite a mensagem que será enviada para $selectedDirectPlayer ou desabilite o Direct")),
        );
        return false;
      }
    }

    return true;
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

  void _salvarResposta(String jogadorId, List<Map<String, dynamic>> players) {
    if (_isDisposed || _isProcessing || !mounted) return;
    if (currentQuestionId == null) return;

    // Valida os campos antes de prosseguir
    if (!_validateFields()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      gameAnsweredQuestions.putIfAbsent(widget.partidaId, () => {});
      gameAnsweredQuestions[widget.partidaId]!.putIfAbsent(jogadorId, () => <String>{});
      gameAnsweredQuestions[widget.partidaId]![jogadorId]!.add(currentQuestionId!);

      final answer = chooseNo ? "Não" : _respostaController.text;
      final perguntaSuperAnonimo = _perguntaSuperAnonimoController.text;
      final superAnonimoAnswer = _respostaSuperAnonimoController.text;
      final mensagemDirect = _mensagemDirectController.text;

      // Verifica se é o primeiro a escolher super anônimo nesta rodada
      bool isSuperAnonimoValid = superAnonimoActive &&
          !gameSuperAnonimoPlayer.containsKey(widget.partidaId);

      if (isSuperAnonimoValid) {
        gameSuperAnonimoPlayer[widget.partidaId] = jogadorId;
      }

      final playersBloc = context.read<PlayersBloc>();
      if (!playersBloc.isClosed) {
        playersBloc.add(
          AddPlayerData(
            widget.partidaId,
            jogadorId,
            currentQuestion!,
            answer,
            isSuperAnonimoValid,
            isSuperAnonimoValid ? perguntaSuperAnonimo : null,
            isSuperAnonimoValid ? superAnonimoAnswer : null,
          ),
        );

        if (selectedDirectPlayer != null && mensagemDirect.isNotEmpty) {
          playersBloc.add(
            SendDirectMessage(
              widget.partidaId,
              jogadorId,
              selectedDirectPlayer!,
              mensagemDirect,
            ),
          );
        }
      }

      final jogadorNome = players.firstWhere((p) => p['id'] == jogadorId)['nome'];
      roundResults.add({
        'jogadorId': jogadorId,
        'jogadorNome': jogadorNome,
        'pergunta': currentQuestion!,
        'resposta': answer,
      });

      // Adiciona resultado do super anônimo se válido
      if (isSuperAnonimoValid) {
        roundResults.add({
          'jogadorId': 'superanonimo',
          'jogadorNome': 'Super Anônimo',
          'pergunta': perguntaSuperAnonimo,
          'resposta': superAnonimoAnswer,
        });
      }

      playersAnsweredThisRound.add(jogadorId);
      _pinController.clear();
      _respostaController.clear();
      _perguntaSuperAnonimoController.clear();
      _respostaSuperAnonimoController.clear();
      _mensagemDirectController.clear();
      chooseNo = false;
      superAnonimoActive = false;
      directActive = false;
      selectedDirectPlayer = null;

      final totalEligiveis = eligiblePlayerIndices.length;
      if (eligiblePointer + 1 >= totalEligiveis) {
        setState(() {
          showRoundResults = true;
          _isProcessing = false;
          currentQuestionId = null;
          currentQuestion = null;
          pinValidado = false;
          hasDirectMessages = false;
          directMessages = [];
        });
      } else {
        eligiblePointer++;
        final nextIndex = eligiblePlayerIndices[eligiblePointer];
        // Troca de jogador deve SEMPRE passar por _setJogadorDaVez
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mensagens Diretas'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: StatefulBuilder( // <- para atualizar dentro do modal
            builder: (context, setStateDialog) {
              return ListView.builder(
                itemCount: directMessages.length,
                itemBuilder: (context, index) {
                  final message = directMessages[index];
                  return Card(
                    child: ListTile(
                      title: const Text('De: **********'),
                      subtitle: Text(message['lida'] ? '(lida)' : '(não lida)'),
                      trailing: !message['lida']
                          ? TextButton(
                        onPressed: () {
                          _showReadMessageDialog(message, jogadorId, setStateDialog);
                        },
                        child: const Text('Ler'),
                      )
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showReadMessageDialog(Map<String, dynamic> message, String jogadorId, void Function(void Function())? setStateDialog) {
    final playersBloc = context.read<PlayersBloc>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mensagem'),
        content: Text(message['mensagem']),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (!message['lida']) {
                // Atualiza no backend
                playersBloc.add(MarkMessageAsRead(widget.partidaId, jogadorId, message['id']));

                // Atualiza na lista principal
                setState(() {
                  final index = directMessages.indexWhere((m) => m['id'] == message['id']);
                  if (index != -1) {
                    directMessages[index]['lida'] = true;
                  }
                });

                // Atualiza também no modal da lista
                if (setStateDialog != null) {
                  setStateDialog(() {});
                }
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showPinDialog(String id, String pinCorreto, List<Map<String, dynamic>> perguntas, List<Map<String, dynamic>> players) {
    _pinController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Validar PIN"),
          content: TextField(
            controller: _pinController,
            enabled: !_isProcessing,
            decoration: const InputDecoration(
              labelText: "Digite o PIN",
              labelStyle: TextStyle(color: Colors.black),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightGreen),
              ),
              counterStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            obscureText: true,
            cursorColor: Colors.green,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (!_isProcessing) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: _isProcessing
                  ? null
                  : () => _checkPin(dialogContext, id, pinCorreto, perguntas, players),
              child: _isProcessing
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text(
                "Confirmar",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return '';
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarGame(),
      body: BlocListener<PlayersBloc, PlayersState>(
        listener: (context, state) {
          if (state is PlayersLoadedWithMessages &&
              _players.isNotEmpty &&
              indice < _players.length) {

            final jogadorAtualId = _players[indice]['id'];

            // 1) só processa se o carregamento foi feito para este jogador
            if (_directsLoadedFor != jogadorAtualId) {
              return;
            }

            // 2) filtra apenas não lidas e que NÃO foram enviadas por ele
            final unread = state.directMessages
                .where((m) => m['lida'] == false && m['remetenteId'] != jogadorAtualId)
                .toList();

            setState(() {
              hasDirectMessages = unread.isNotEmpty;
              directMessages = unread;
            });
          }
        },
        child: Stack(
          children: [
            // fundo
            Positioned.fill(
              child:
              Image.asset("images/background_anonimo.jpg", fit: BoxFit.cover),
            ),

            // overlay escuro
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.of(context).padding.top + 50,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: BlocBuilder<PlayersBloc, PlayersState>(
                builder: (context, playersState) {
                  if (playersState is PlayersLoaded || playersState is PlayersLoadedWithMessages) {
                    _players = playersState is PlayersLoadedWithMessages
                        ? (playersState).players
                        : (playersState as PlayersLoaded).players;

                    // Ordena pelo campo 'indice' (crescente)
                    _players.sort((a, b) => (a['indice'] as int).compareTo(b['indice'] as int));

                    return BlocBuilder<QuestionsBloc, QuestionsState>(
                      builder: (context, questionsState) {
                        if (questionsState is QuestionsLoaded) {
                          final perguntas = questionsState.questions;

                          if (!_roundPrepared) {
                            final localEligible = <int>[];
                            for (var i = 0; i < _players.length; i++) {
                              final pid = _players[i]['id'];
                              if (_hasAvailableQuestionForPlayer(pid, perguntas, _players)) {
                                localEligible.add(i);
                              }
                            }

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_isDisposed) return;
                              if (localEligible.isEmpty) {
                                final allDone = allQuestionsAnsweredByEverybody(perguntas, _players);
                                setState(() {
                                  gameOver = allDone;
                                  _roundPrepared = true;
                                  eligiblePlayerIndices = [];
                                });
                              } else {
                                setState(() {
                                  eligiblePlayerIndices = localEligible;
                                  eligiblePointer = 0;
                                  roundResults.clear();
                                  playersAnsweredThisRound.clear();
                                  showRoundResults = false;
                                  gameOver = false;
                                  _roundPrepared = true;
                                });
                                _setJogadorDaVez(eligiblePlayerIndices[0]);
                              }
                            });
                          }

                          if (gameOver) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Acabaram todas as perguntas!", style: TextStyle(color: Colors.white, fontSize: 18)),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        gameAnsweredQuestions.remove(widget.partidaId);
                                        gameSuperAnonimoPlayer.remove(widget.partidaId);
                                        gameOver = false;
                                        _roundPrepared = false;
                                        roundResults.clear();
                                      });
                                    },
                                    child: const Text("Iniciar novo jogo"),
                                  )
                                ],
                              ),
                            );
                          }

                          if (showRoundResults) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  const Text("Resultados da rodada", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: roundResults.length,
                                      itemBuilder: (context, index) {
                                        final item = roundResults[index];
                                        return Card(
                                          margin: const EdgeInsets.all(8),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Jogador: ${item['jogadorNome']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 6),
                                                Text("Pergunta: ${item['pergunta']}"),
                                                const SizedBox(height: 6),
                                                Text("Resposta: ${item['resposta']}"),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text("Jogar nova rodada"),
                                    onPressed: () {
                                      final allDone = allQuestionsAnsweredByEverybody(perguntas, _players);
                                      if (allDone) {
                                        setState(() {
                                          gameOver = true;
                                        });
                                      } else {
                                        _startNewRound(_players, perguntas);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }

                          if (eligiblePlayerIndices.isEmpty) {
                            return const Center(child: Text("Nenhuma pergunta disponível no momento", style: TextStyle(color: Colors.white),));
                          }

                          if (!eligiblePlayerIndices.contains(indice)) {
                            if (eligiblePointer < eligiblePlayerIndices.length) {
                              _setJogadorDaVez(eligiblePlayerIndices[eligiblePointer]);
                            } else {
                              setState(() {
                                eligiblePointer = 0;
                              });
                              _setJogadorDaVez(eligiblePlayerIndices[0]);
                            }
                          }

                          final jogador = _players[indice];
                          final nome = jogador['nome'];
                          final id = jogador['id'];
                          final pinCorreto = jogador['pin'].toString();
                          _getNewQuestion(id, perguntas, _players);

                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jogador:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundImage: AssetImage('images/espiao.jpg'),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _capitalize("$nome"),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    if (hasDirectMessages && pinValidado)
                                      IconButton(
                                        onPressed: () => _showDirectMessagesDialog(id),
                                        icon: const Badge(
                                          child: Icon(Icons.message, color: Colors.blue, size: 30),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 50),

                                if (!pinValidado) ...[
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: _isProcessing
                                          ? null
                                          : () => _showPinDialog(id, pinCorreto, perguntas, _players),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white70,
                                        foregroundColor: Colors.black,
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(15),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.visibility, size: 24),
                                            SizedBox(width: 15),
                                            Text('Ver Pergunta', style: TextStyle(fontSize: 18)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  if (currentQuestionId == null) ...[
                                    const Text("Você já respondeu todas as perguntas disponíveis!", style: TextStyle(color: Colors.white),),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (eligiblePointer + 1 < eligiblePlayerIndices.length) {
                                          eligiblePointer++;
                                          _setJogadorDaVez(eligiblePlayerIndices[eligiblePointer]);
                                          setState(() {
                                            pinValidado = false;
                                            currentQuestionId = null;
                                            currentQuestion = null;
                                          });
                                        } else {
                                          setState(() {
                                            showRoundResults = true;
                                          });
                                        }
                                      },
                                      child: const Text("Próximo Jogador"),
                                    ),
                                  ],

                                  if (currentQuestionId != null) ...[
                                    Expanded(
                                      child: SingleChildScrollView(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "$currentQuestion",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            TextField(
                                              controller: _respostaController,
                                              enabled: !_isProcessing,
                                              maxLines: null, // Permite quebra de linha automática
                                              keyboardType: TextInputType.multiline,
                                              onTap: () {
                                                if (chooseNo) {
                                                  setState(() => chooseNo = false);
                                                }
                                              },
                                              onChanged: (value) {
                                                if (chooseNo && value.trim().isNotEmpty) {
                                                  setState(() => chooseNo = false);
                                                }
                                              },
                                              decoration: const InputDecoration(
                                                labelText: "Sua resposta",
                                                labelStyle: TextStyle(color: Colors.white),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.white),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.lightGreen),
                                                ),
                                              ),
                                              cursorColor: Colors.green,
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                            Row(
                                              children: [
                                                Radio<bool>(
                                                  value: true,
                                                  activeColor: Colors.white,
                                                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                                    if (states.contains(WidgetState.disabled)) {
                                                      return Colors.grey;
                                                    } else if (states.contains(WidgetState.selected)) {
                                                      return Colors.green;
                                                    }
                                                    return Colors.white;
                                                  }),
                                                  overlayColor: WidgetStateProperty.all(Colors.lightGreenAccent.withOpacity(0.2)),
                                                  groupValue: chooseNo ? true : null,
                                                  onChanged: _respostaController.text.trim().isEmpty
                                                      ? (value) {
                                                    setState(() => chooseNo = value ?? false);
                                                  }
                                                      : null,
                                                ),
                                                const Text("Não", style: TextStyle(color: Colors.white),),
                                              ],
                                            ),
                                            SwitchListTile(
                                              title: const Text("Responder como SuperAnônimo", style: TextStyle(color: Colors.white),),
                                              value: superAnonimoActive,
                                              onChanged: (value) {
                                                setState(() {
                                                  superAnonimoActive = value;
                                                  if (!value) {
                                                    _resetSuperAnonimoFields();
                                                  }
                                                });
                                              },
                                            ),
                                            if (superAnonimoActive) ...[
                                              const SizedBox(height: 10),
                                              TextField(
                                                controller: _perguntaSuperAnonimoController,
                                                maxLines: null,
                                                keyboardType: TextInputType.multiline,
                                                decoration: const InputDecoration(
                                                  labelText: "Digite sua pergunta - Super Anônimo",
                                                  labelStyle: TextStyle(color: Colors.white),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.white),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.lightGreen),
                                                  ),
                                                ),
                                                cursorColor: Colors.green,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                              const SizedBox(height: 10),
                                              TextField(
                                                controller: _respostaSuperAnonimoController,
                                                maxLines: null,
                                                keyboardType: TextInputType.multiline,
                                                decoration: const InputDecoration(
                                                  labelText: "Sua resposta - Super Anônimo",
                                                  labelStyle: TextStyle(color: Colors.white),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.white),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.lightGreen),
                                                  ),
                                                ),
                                                cursorColor: Colors.green,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ],
                                            const SizedBox(height: 20),
                                            SwitchListTile(
                                              title: const Text("Enviar Direct", style: TextStyle(color: Colors.white),),
                                              value: directActive,
                                              onChanged: (value) {
                                                setState(() {
                                                  directActive = value;
                                                  if (!value) {
                                                    _resetDirectFields();
                                                  }
                                                });
                                              },
                                            ),
                                            if (directActive) ...[
                                              const SizedBox(height: 10),
                                              Column(
                                                children: [
                                                  const Text("Mandar direct para:", style: TextStyle(color: Colors.white),),
                                                  const SizedBox(height: 10),
                                                  DropdownButton<String>(
                                                    value: selectedDirectPlayer,
                                                    style: const TextStyle(color: Colors.white),
                                                    dropdownColor: Colors.black,
                                                    hint: const Text("Selecione um jogador", style: TextStyle(color: Colors.white),),
                                                    items: _players.where((p) => p['id'] != id).map<DropdownMenuItem<String>>((p) {
                                                      return DropdownMenuItem<String>(
                                                        value: p['id'],
                                                        child: Text(p['nome']),
                                                      );
                                                    }).toList(),
                                                    onChanged: (value) {
                                                      setState(() => selectedDirectPlayer = value);
                                                    },
                                                  ),
                                                  if (selectedDirectPlayer != null) ...[
                                                    const SizedBox(height: 10),
                                                    TextField(
                                                      controller: _mensagemDirectController,
                                                      maxLines: null,
                                                      keyboardType: TextInputType.multiline,
                                                      decoration: const InputDecoration(
                                                        labelText: "Digite sua mensagem - Direct",
                                                        labelStyle: TextStyle(color: Colors.white),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(color: Colors.white),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderSide: BorderSide(color: Colors.lightGreen),
                                                        ),
                                                      ),
                                                      cursorColor: Colors.green,
                                                      style: const TextStyle(color: Colors.white),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                            const SizedBox(height: 80), // espaço para não cobrir o botão
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      color: Colors.black.withOpacity(0.5),
                                      child: ElevatedButton(
                                        onPressed: _isProcessing ? null : () => _salvarResposta(id, _players),
                                        child: _isProcessing
                                            ? const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                            SizedBox(width: 8),
                                            Text("Salvando..."),
                                          ],
                                        )
                                            : const Text("Salvar"),
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          );
                        } else if (questionsState is QuestionsLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (questionsState is QuestionsError) {
                          return Center(child: Text("Erro ao carregar perguntas: ${questionsState.message}", style: TextStyle(color: Colors.white),));
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    );
                  } else if (playersState is PlayersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (playersState is PlayersError) {
                    return Center(child: Text("Erro ao carregar jogadores: ${playersState.message}", style: TextStyle(color: Colors.white),));
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
}