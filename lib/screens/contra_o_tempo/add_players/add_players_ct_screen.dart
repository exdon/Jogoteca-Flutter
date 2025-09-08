import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/contra_o_tempo/players/players_bloc_ct.dart';
import 'package:jogoteca/blocs/contra_o_tempo/players/players_event_ct.dart';
import 'package:jogoteca/blocs/contra_o_tempo/players/players_state_ct.dart';
import 'package:jogoteca/blocs/contra_o_tempo/questions/questions_bloc_ct.dart';
import 'package:jogoteca/blocs/contra_o_tempo/questions/questions_event_ct.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/constants/contra_o_tempo/contra_o_tempo_constants.dart';
import 'package:jogoteca/guards/game_pop_guard.dart';
import 'package:jogoteca/screens/contra_o_tempo/add_players/add_players_ct_validator.dart';
import 'package:jogoteca/screens/contra_o_tempo/add_players/widgets_ct_build.dart';
import 'package:jogoteca/screens/contra_o_tempo/game/contra_o_tempo_game_screen.dart';
import 'package:jogoteca/service/contra_o_tempo/contra_o_tempo_service.dart';
import 'package:jogoteca/shared/service/shared_service.dart';
import 'package:jogoteca/shared/shared_functions.dart';
import 'package:jogoteca/widget/app_bar_game.dart';

class AddPlayersCTScreen extends StatefulWidget {
  final String partidaId;

  const AddPlayersCTScreen({super.key, required this.partidaId});

  @override
  State<AddPlayersCTScreen> createState() => _AddPlayersCTScreenState();
}

class _AddPlayersCTScreenState extends State<AddPlayersCTScreen> with TickerProviderStateMixin {
  bool isAdding = false;
  final _nomeController = TextEditingController();
  String nomeJogador = '';
  int jogadorIndice = 0;
  bool jogadorAcabouDeSerAdicionado = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Animação de pulso suave
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);

    context.read<PlayersBlocCT>().add(LoadPlayersCT(widget.partidaId));
    SharedService(
      gameId: ContraOTempoConstants.gameId,
      database: ContraOTempoConstants.dbPartidas,
      partidaId: widget.partidaId,
    ).setPartidaAtiva(true);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _cancelAddingPlayer() {
    _resetTextFields();
    setState(() => isAdding = false);
  }

  void _resetTextFields() {
    _nomeController.clear();
  }

  void _savePlayer() {
    final nome = _nomeController.text.trim();

    nomeJogador = nome;

    setState(() {
      jogadorIndice++;
    });

    final validation = AddPlayersCTValidator.validatePlayerData(nome);

    if (validation['nome'] != null) {
      SharedFunctions.showSnackMessage(message: validation['nome']!, mounted: mounted, context: context);
      return;
    }

    try {
      context.read<PlayersBlocCT>().add(
        AddPlayerCT(
          widget.partidaId,
          nome,
          jogadorIndice,
        ),
      );
      jogadorAcabouDeSerAdicionado = true;
    } catch (e) {
      SharedFunctions.showSnackMessage(
        message: 'Erro ao salvar jogador ${SharedFunctions.capitalize(nome)} - $e',
        mounted: mounted,
        context: context,
      );
    }

    setState(() {
      isAdding = false;
      _resetTextFields();
    });
  }

  void _startGame() {
    if (!mounted) return;

    final playersBloc = context.read<PlayersBlocCT>();

    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: playersBloc..add(LoadPlayersCT(widget.partidaId)),
                ),
                BlocProvider(
                  create: (_) => QuestionsBlocCT(ContraOTempoService())
                    ..add(LoadQuestionsCT()),
                ),
              ],
            child: ContraOTempoGameScreen(partidaId: widget.partidaId),
          ),
        ),
      );
    } catch (e) {
      SharedFunctions.showSnackMessage(
        message: 'Erro ao iniciar jogo: $e',
        mounted: mounted,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return GamePopGuard(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBarGame(
          disablePartida: true,
          deletePartida: true,
          partidaId: widget.partidaId,
          gameId: ContraOTempoConstants.gameId,
          database: ContraOTempoConstants.dbPartidas,
        ),
        body: Stack(
          children: [
            // Gradiente de fundo com tons de azul claro
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF87CEEB), // Sky Blue
                      Color(0xFF4682B4), // Steel Blue
                      Color(0xFF1E90FF), // Dodger Blue
                      Color(0xFF0077BE), // Azure Blue
                    ],
                    stops: [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            // Efeito de pulso animado
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Colors.lightBlue.withValues(alpha: _pulseAnimation.value * 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Overlay sutil para suavizar
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            // Conteúdo principal
            BlocListener<PlayersBlocCT, PlayersStateCT>(
              listener: (context, state) {
                if (state is PlayersErrorCT) {
                  SharedFunctions.showSnackMessage(
                      message: 'Erro ao adicionar jogador(a) ${SharedFunctions.capitalize(nomeJogador)}: ${state.message}',
                      mounted: mounted,
                      context: context
                  );
                } else if (state is PlayersLoadedCT) {
                  if (jogadorAcabouDeSerAdicionado && state.players.isNotEmpty) {
                    SharedFunctions.showSnackMessage(
                        message: 'Jogador(a) ${SharedFunctions.capitalize(nomeJogador)} adicionado com sucesso!',
                        mounted: mounted,
                        context: context
                    );
                    jogadorAcabouDeSerAdicionado = false;
                  }
                }
              },
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: kToolbarHeight + 50,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    children: [
                      _buildTopSection(),
                      const SizedBox(height: 24),
                      _buildPlayersListSection(),
                      const SizedBox(height: 12),
                      if (!isKeyboardOpen)
                        _buildBottomSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    if (isAdding) {
      return WidgetsCTBuild.buildPlayerFields(
        nomeController: _nomeController,
        onCancel: _cancelAddingPlayer,
        onSave: _savePlayer,
      );
    } else {
      return WidgetsCTBuild.buildAddButton(
        onPressed: () => setState(() => isAdding = true),
      );
    }
  }

  Widget _buildPlayersListSection() {
    return Expanded(
      child: BlocBuilder<PlayersBlocCT, PlayersStateCT>(builder: (context, state) {
        if (state is PlayersLoadingCT) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade800),
              strokeWidth: 3,
            ),
          );
        } else if (state is PlayersLoadedCT) {
          return WidgetsCTBuild.buildPlayersList(players: state.players);
        } else if (state is PlayersErrorCT) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                border: Border.all(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Erro: ${state.message}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
      ),
    );
  }

  Widget _buildBottomSection() {
    return BlocBuilder<PlayersBlocCT, PlayersStateCT>(builder: (context, state) {
      final bool canStart = state is PlayersLoadedCT && state.players.isNotEmpty;

      return Column(
        children: [
          WidgetsCTBuild.buildStartGameButton(
            onPressed: canStart ? _startGame : null,
          ),
          const SizedBox(height: 25),
        ],
      );
    });
  }
}
