import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/voce_me_conhece/players/players_bloc_vmc.dart';
import 'package:jogoteca/blocs/voce_me_conhece/players/players_event_vmc.dart';
import 'package:jogoteca/blocs/voce_me_conhece/players/players_state_vmc.dart';
import 'package:jogoteca/blocs/voce_me_conhece/questions/questions_bloc_vmc.dart';
import 'package:jogoteca/blocs/voce_me_conhece/questions/questions_event_vmc.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/constants/contra_o_tempo/contra_o_tempo_constants.dart';
import 'package:jogoteca/constants/voce_me_conhece/voce_me_conhece_constants.dart';
import 'package:jogoteca/guards/game_pop_guard.dart';
import 'package:jogoteca/screens/voce_me_conhece/add_players/add_players_vmc_validator.dart';
import 'package:jogoteca/screens/voce_me_conhece/add_players/widgets_vmc_build.dart';
import 'package:jogoteca/screens/voce_me_conhece/game/voce_me_conhece_game_screen.dart';
import 'package:jogoteca/service/voce_me_conhece/voce_me_conhece_service.dart';
import 'package:jogoteca/shared/service/shared_service.dart';
import 'package:jogoteca/shared/shared_functions.dart';
import 'package:jogoteca/widget/app_bar_game.dart';


class AddPlayersVMCScreen extends StatefulWidget {
  final String partidaId;

  const AddPlayersVMCScreen({super.key, required this.partidaId});

  @override
  State<AddPlayersVMCScreen> createState() => _AddPlayersVMCScreenState();
}

class _AddPlayersVMCScreenState extends State<AddPlayersVMCScreen> {

  bool isAdding = false;
  final _nomeController = TextEditingController();
  String nomeJogador = '';
  int jogadorIndice = 0;

  bool jogadorAcabouDeSerAdicionado = false;


  @override
  void initState() {
    super.initState();

    context.read<PlayersBlocVMC>().add(LoadPlayersVMC(widget.partidaId));
    SharedService(
      gameId: VoceMeConheceConstants.gameId,
      database: VoceMeConheceConstants.dbPartidas,
      partidaId: widget.partidaId,
    ).setPartidaAtiva(true);
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

    setState(() {
      jogadorIndice++;
    });

    final validation = AddPlayersVMCValidator.validatePlayerData(nome);

    if (validation['nome'] != null) {
      SharedFunctions.showSnackMessage(message: validation['nome']!, mounted: mounted, context: context);
      return;
    }

    try {
      context.read<PlayersBlocVMC>().add(
        AddPlayerVMC(
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

    final playersBloc = context.read<PlayersBlocVMC>();

    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: playersBloc..add(LoadPlayersVMC(widget.partidaId)),
                ),
                BlocProvider(
                  create: (_) => QuestionsBlocVMC(VoceMeConheceService())
                    ..add(LoadQuestionsVMC()),
                ),
              ],
            child: VoceMeConheceGameScreen(partidaId: widget.partidaId),
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
        child: SafeArea(
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBarGame(
              disablePartida: true,
              deletePartida: true,
              partidaId: widget.partidaId,
              gameId: ContraOTempoConstants.gameId,
              database: ContraOTempoConstants.dbPartidas,
            ),
            body: BlocListener<PlayersBlocVMC, PlayersStateVMC>(
              listener: (context, state) {
                if (state is PlayersErrorVMC) {
                  SharedFunctions.showSnackMessage(
                      message: 'Erro ao adicionar jogador(a) ${SharedFunctions.capitalize(nomeJogador)}: ${state.message}',
                      mounted: mounted,
                      context: context
                  );
                } else if (state is PlayersLoadedVMC) {
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
              child: Stack(
                children: [
                  // Fundo
                  Positioned.fill(
                    child: Image.asset(AppConstants.backgroundVoceMeConhece, fit: BoxFit.cover),
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
          ),
        ),
    );
  }

  Widget _buildTopSection() {
    if (isAdding) {
      return WidgetsVMCBuild.buildPlayerFields(
        nomeController: _nomeController,
        onCancel: _cancelAddingPlayer,
        onSave: _savePlayer,
      );
    } else {
      return WidgetsVMCBuild.buildAddButton(
        onPressed: () => setState(() => isAdding = true),
      );
    }
  }

  Widget _buildPlayersListSection() {
    return Expanded(
      child: BlocBuilder<PlayersBlocVMC, PlayersStateVMC>(builder: (context, state) {
        if (state is PlayersLoadingVMC) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PlayersLoadedVMC) {
          return WidgetsVMCBuild.buildPlayersList(players: state.players);
        } else if (state is PlayersErrorVMC) {
          return Center(child: Text('Erro: ${state.message}', style: TextStyle(color: Colors.white),));
        } else {
          return const SizedBox.shrink();
        }
      },
      ),
    );
  }

  Widget _buildBottomSection() {
    return BlocBuilder<PlayersBlocVMC, PlayersStateVMC>(builder: (context, state) {

      final bool canStart = state is PlayersLoadedVMC && state.players.isNotEmpty;

      return Column(
        children: [
          WidgetsVMCBuild.buildStartGameButton(
            onPressed: canStart ? _startGame : null,
          ),
          const SizedBox(height: 16),
          // Seção para entrar em jogo existente
          // AddPlayersVMCWidgets.buildJoinGameSection(
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
