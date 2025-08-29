import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/contra_o_tempo/players/players_bloc_ct.dart';
import 'package:jogoteca/blocs/contra_o_tempo/players/players_event_ct.dart';
import 'package:jogoteca/blocs/contra_o_tempo/players/players_state_ct.dart';
import 'package:jogoteca/blocs/contra_o_tempo/questions/questions_bloc_ct.dart';
import 'package:jogoteca/blocs/contra_o_tempo/questions/questions_event_ct.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/constants/contra_o_tempo/contra_o_tempo_constants.dart';
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

class _AddPlayersCTScreenState extends State<AddPlayersCTScreen> {

  bool isAdding = false;
  final _nomeController = TextEditingController();
  String nomeJogador = '';
  int jogadorIndice = 0;

  bool jogadorAcabouDeSerAdicionado = false;


  @override
  void initState() {
    super.initState();

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarGame(
        disablePartida: true,
        deletePartida: true,
        partidaId: widget.partidaId,
        gameId: ContraOTempoConstants.gameId,
        database: ContraOTempoConstants.dbPartidas,
      ),
      body: BlocListener<PlayersBlocCT, PlayersStateCT>(
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
          return const Center(child: CircularProgressIndicator());
        } else if (state is PlayersLoadedCT) {
          return WidgetsCTBuild.buildPlayersList(players: state.players);
        } else if (state is PlayersErrorCT) {
          return Center(child: Text('Erro: ${state.message}', style: TextStyle(color: Colors.white),));
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
          const SizedBox(height: 16),
          // Seção para entrar em jogo existente
          // AddPlayersCTWidgets.buildJoinGameSection(
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
