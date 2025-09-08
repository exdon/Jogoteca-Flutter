import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/responda_ou_pague/challenges/challenges_bloc_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/players/players_bloc_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/players/players_event_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/players/players_state_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/questions/questions_bloc_rp.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/constants/responda_ou_pague/responda_ou_pague_constants.dart';
import 'package:jogoteca/guards/game_pop_guard.dart';
import 'package:jogoteca/screens/responda_ou_pague/add_players/add_players_rp_validator.dart';
import 'package:jogoteca/screens/responda_ou_pague/add_players/widgets_rp_build.dart';
import 'package:jogoteca/screens/responda_ou_pague/game/responda_ou_pague_game_screen.dart';
import 'package:jogoteca/service/responda_ou_pague/responsa_ou_pague_service.dart';
import 'package:jogoteca/shared/service/shared_service.dart';
import 'package:jogoteca/shared/shared_functions.dart';
import 'package:jogoteca/widget/app_bar_game.dart';
import 'package:jogoteca/widget/responda_ou_pague/game_intro_screen.dart';

class AddPlayersRPScreen extends StatefulWidget {
  final String partidaId;

  const AddPlayersRPScreen({super.key, required this.partidaId});

  @override
  State<AddPlayersRPScreen> createState() => _AddPlayersRPScreenState();
}

class _AddPlayersRPScreenState extends State<AddPlayersRPScreen>
    with TickerProviderStateMixin {
  bool isAdding = false;
  final _nomeController = TextEditingController();
  String nomeJogador = '';
  bool jogadorFoiAdicionado = false;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animações
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    context.read<PlayersBlocRP>().add(LoadPlayersRP(widget.partidaId));
    SharedService(
      gameId: RespondaOuPagueConstants.gameId,
      database: RespondaOuPagueConstants.dbPartidas,
      partidaId: widget.partidaId,
    ).setPartidaAtiva(true);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _glowController.dispose();
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

    final validation = AddPlayersRPValidator.validatePlayerData(nome);

    if (validation['nome'] != null) {
      SharedFunctions.showSnackMessage(message: validation['nome']!, mounted: mounted, context: context);
      return;
    }

    try {
      context.read<PlayersBlocRP>().add(
        AddPlayerRP(widget.partidaId, nome),
      );
      jogadorFoiAdicionado = true;
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
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameIntroScreen(
            onFinish: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: context.read<PlayersBlocRP>()),
                            BlocProvider(
                                create: (_) =>
                                    QuestionsBlocRP(ResponsaOuPagueService()),
                            ),
                            BlocProvider(
                              create: (_) =>
                                  ChallengesBlocRP(ResponsaOuPagueService()),
                            ),
                          ],
                          child: RespondaOuPagueGameScreen(partidaId: widget.partidaId),
                      ),
                  ),
              );
            },
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
          resizeToAvoidBottomInset: false, // Impede que o Scaffold redimensione com o teclado
          appBar: AppBarGame(
            disablePartida: true,
            deletePartida: true,
            partidaId: widget.partidaId,
            gameId: RespondaOuPagueConstants.gameId,
            database: RespondaOuPagueConstants.dbPartidas,
          ),
          body: BlocListener<PlayersBlocRP, PlayersStateRP>(
            listener: (context, state) {
              if (state is PlayersErrorRP) {
                SharedFunctions.showSnackMessage(
                    message: 'Erro ao adicionar jogador(a) ${SharedFunctions.capitalize(nomeJogador)}: ${state.message}',
                    mounted: mounted,
                    context: context
                );
              } else if (state is PlayersLoadedRP && jogadorFoiAdicionado) {
                if (state.players.isNotEmpty) {
                  SharedFunctions.showSnackMessage(
                      message: 'Jogador(a) ${SharedFunctions.capitalize(nomeJogador)} adicionado com sucesso!',
                      mounted: mounted,
                      context: context
                  );
                  jogadorFoiAdicionado = false;
                }
              }
            },
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: Image.asset(
                        AppConstants.backgroundRespondaOuPague,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Gradient overlay com animação
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.purple.withOpacity(0.2 * _glowAnimation.value),
                              Colors.cyan.withOpacity(0.15 * _glowAnimation.value),
                              Colors.black.withOpacity(0.6),
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Efeito de partículas
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.5 * _pulseAnimation.value,
                                colors: [
                                  Colors.cyan.withOpacity(0.05 * _glowAnimation.value),
                                  Colors.purple.withOpacity(0.03 * _glowAnimation.value),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Conteúdo principal com SingleChildScrollView
                    SafeArea(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: kToolbarHeight + 10,
                          left: 16,
                          right: 16,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 16, // Considera o teclado
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height -
                                       MediaQuery.of(context).padding.top -
                                       kToolbarHeight -
                                       MediaQuery.of(context).viewInsets.bottom - 60,
                          ),
                          child: Column(
                            children: [
                              _buildTopSection(),
                              const SizedBox(height: 16),
                              _buildPlayersListSection(isKeyboardOpen),
                              const SizedBox(height: 16),
                              if (!isKeyboardOpen)
                                _buildBottomSection(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
    );
  }

  Widget _buildTopSection() {
    if (isAdding) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: WidgetsRPBuild.buildPlayerFields(
          nomeController: _nomeController,
          onCancel: _cancelAddingPlayer,
          onSave: _savePlayer,
        ),
      );
    } else {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.cyan.withOpacity(0.05),
              Colors.purple.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        Colors.cyan.withOpacity(0.1 * _glowAnimation.value),
                        Colors.purple.withOpacity(0.1 * _glowAnimation.value),
                      ],
                    ),
                  ),
                  child: const Text(
                    'Responda ou Pague',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Prepare-se para perguntas e desafios reveladores!\nAdicione jogadores para começar.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: WidgetsRPBuild.buildAddButton(
                    onPressed: () => setState(() => isAdding = true),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPlayersListSection(bool isKeyboardOpen) {
    return Container(
      height: isKeyboardOpen ? 200 : 300, // Altura fixa baseada no estado do teclado
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.black.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BlocBuilder<PlayersBlocRP, PlayersStateRP>(
          builder: (context, state) {
            if (state is PlayersLoadingRP) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Carregando jogadores...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              );
            } else if (state is PlayersLoadedRP) {
              return WidgetsRPBuild.buildPlayersList(
                players: state.players,
                isKeyboardOpen: isKeyboardOpen,
              );
            } else if (state is PlayersErrorRP) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Erro: ${state.message}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text(
                  'Estado desconhecido',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return BlocBuilder<PlayersBlocRP, PlayersStateRP>(
      builder: (context, state) {
        final bool canStart = state is PlayersLoadedRP && state.players.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.cyan.withOpacity(0.03),
                Colors.purple.withOpacity(0.03),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: canStart ? [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.3 * _glowAnimation.value),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ] : [],
                    ),
                    child: WidgetsRPBuild.buildStartGameButton(
                      onPressed: canStart ? _startGame : null,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
