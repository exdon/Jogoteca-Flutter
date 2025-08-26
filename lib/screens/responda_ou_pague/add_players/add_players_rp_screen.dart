import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/responda_ou_pague/challenges/challenges_bloc_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/players/players_bloc_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/players/players_event_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/players/players_state_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/questions/questions_bloc_rp.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/screens/responda_ou_pague/add_players/add_players_rp_validator.dart';
import 'package:jogoteca/screens/responda_ou_pague/add_players/widgets_rp_build.dart';
import 'package:jogoteca/screens/responda_ou_pague/game/responda_ou_pague_game_screen.dart';
import 'package:jogoteca/service/responda_ou_pague/responsa_ou_pague_service.dart';
import 'package:jogoteca/shared/shared_functions.dart';
import 'package:jogoteca/widget/app_bar_game.dart';
import 'package:jogoteca/widget/responda_ou_pague/game_intro_screen.dart';

class AddPlayersRPScreen extends StatefulWidget {
  final String partidaId;

  const AddPlayersRPScreen({super.key, required this.partidaId});

  @override
  State<AddPlayersRPScreen> createState() => _AddPlayersRPScreenState();
}

class _AddPlayersRPScreenState extends State<AddPlayersRPScreen> {
  bool isAdding = false;
  final _nomeController = TextEditingController();
  String nomeJogador = '';

  @override
  void initState() {
    super.initState();

    context.read<PlayersBlocRP>().add(LoadPlayersRP(widget.partidaId));
  }


  @override
  void dispose() {
    _nomeController.dispose();
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarGame(disablePartida: true, deletePartida: true, partidaId: widget.partidaId),
      body: BlocListener<PlayersBlocRP, PlayersStateRP>(
        listener: (context, state) {
          if (state is PlayersErrorRP) {
            SharedFunctions.showSnackMessage(
                message: 'Erro ao adicionar jogador(a) ${SharedFunctions.capitalize(nomeJogador)}: ${state.message}',
                mounted: mounted,
                context: context
            );
          } else if (state is PlayersLoadedRP) {
            if (state.players.isNotEmpty) {
              SharedFunctions.showSnackMessage(
                  message: 'Jogador(a) ${SharedFunctions.capitalize(nomeJogador)} adicionado com sucesso!',
                  mounted: mounted,
                  context: context
              );
            }
          }
        },
        child: Stack(
          children: [
            // Fundo
            Positioned.fill(
              child: Image.asset(AppConstants.backgroundRespondaOuPague, fit: BoxFit.cover),
            ),
            // Overlay escuro
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
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    if (isAdding) {
      return WidgetsRPBuild.buildPlayerFields(
        nomeController: _nomeController,
        onCancel: _cancelAddingPlayer,
        onSave: _savePlayer,
      );
    } else {
      return WidgetsRPBuild.buildAddButton(
        onPressed: () => setState(() => isAdding = true),
      );
    }
  }

  Widget _buildPlayersListSection() {
    return Expanded(
      child: BlocBuilder<PlayersBlocRP, PlayersStateRP>(builder: (context, state) {
        if (state is PlayersLoadingRP) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PlayersLoadedRP) {
          return WidgetsRPBuild.buildPlayersList(players: state.players);
        } else if (state is PlayersErrorRP) {
          return Center(child: Text('Erro: ${state.message}'));
        } else {
          return const SizedBox.shrink();
        }
      },
      ),
    );
  }

  Widget _buildBottomSection() {
    return BlocBuilder<PlayersBlocRP, PlayersStateRP>(builder: (context, state) {

      final bool canStart = state is PlayersLoadedRP && state.players.isNotEmpty;

      return Column(
        children: [
          WidgetsRPBuild.buildStartGameButton(
            onPressed: canStart ? _startGame : null,
          ),
          const SizedBox(height: 16),
          // Seção para entrar em jogo existente
          // AddPlayersWidgets.buildJoinGameSection(
          //   partidaIdController: _partidaIdController,
          //   isNavigating: _isNavigating,
          //   onJoinGame: _navigateToJoinGame,
          // ),
        ],
      );

    },
    );
  }
}
