import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/players/players_bloc.dart';
import 'package:jogoteca/blocs/players/players_event.dart';
import 'package:jogoteca/blocs/players/players_state.dart';
import 'package:jogoteca/screens/prazer_anonimo/add_players/add_players_validator.dart';
import 'package:jogoteca/screens/prazer_anonimo/add_players/widgets_build.dart';
import 'package:jogoteca/service/firebase_service.dart';
import 'package:jogoteca/shared/shared_functions.dart';
import 'package:jogoteca/widget/app_bar_game.dart';
import 'package:jogoteca/widget/hacker_transition_screen.dart';


class AddPlayersScreen extends StatefulWidget {
  final String partidaId;

  const AddPlayersScreen({super.key, required this.partidaId});

  @override
  State<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {

  bool isAdding = false;
  final _nomeController = TextEditingController();
  final _pinController = TextEditingController();
  String nomeJogador = '';
  int jogadorIndice = 0;

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    context.read<PlayersBloc>().add(LoadPlayers(widget.partidaId));
    FirebaseService().setPartidaAtiva(widget.partidaId, true);
  }


  @override
  void dispose() {
    _nomeController.dispose();
    _pinController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _cancelAddingPlayer() {
    _resetTextFields();
    setState(() => isAdding = false);
  }

  void _resetTextFields() {
    _nomeController.clear();
    _pinController.clear();
  }

  // para aparecer a msg de justificativa de add jogadores no tooltip
  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      return;
    }

    _overlayEntry = WidgetsBuild.createInfoOverlay(
      context: context,
      onClose: () {
        _overlayEntry?.remove();
        _overlayEntry = null;
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _savePlayer() {
    final nome = _nomeController.text.trim();
    final pin = _pinController.text.trim();

    nomeJogador = nome;
    // jogadorPin = pin;

    setState(() {
      jogadorIndice++;
    });

    final validation = AddPlayersValidator.validatePlayerData(nome, pin);

    if (validation['nome'] != null) {
      SharedFunctions.showSnackMessage(message: validation['nome']!, mounted: mounted, context: context);
      return;
    }

    if (validation['pin'] != null) {
      SharedFunctions.showSnackMessage(message: validation['pin']!, mounted: mounted, context: context);
      return;
    }

    try {
      context.read<PlayersBloc>().add(
          AddPlayer(
            widget.partidaId,
            jogadorIndice,
            nome,
            int.parse(pin),
          ),
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HackerTransitionScreen(
            partidaId: widget.partidaId,
            playersBloc: context.read<PlayersBloc>(),
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarGame(disablePartida: true, deletePartida: true, partidaId: widget.partidaId),
      body: BlocListener<PlayersBloc, PlayersState>(
        listener: (context, state) {
          if (state is PlayersError) {
            SharedFunctions.showSnackMessage(
                message: 'Erro ao adicionar jogador(a) ${SharedFunctions.capitalize(nomeJogador)}: ${state.message}',
                mounted: mounted,
                context: context
            );
          } else if (state is PlayersLoaded) {
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
              child: Image.asset("images/background_anonimo.jpg", fit: BoxFit.cover),
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
      return WidgetsBuild.buildPlayerFields(
          nomeController: _nomeController,
          pinController: _pinController,
          onCancel: _cancelAddingPlayer,
          onSave: _savePlayer,
      );
    } else {
      return WidgetsBuild.buildAddButton(
        onPressed: () => setState(() => isAdding = true),
      );
    }
  }

  Widget _buildPlayersListSection() {
    return Expanded(
      child: BlocBuilder<PlayersBloc, PlayersState>(builder: (context, state) {
          if (state is PlayersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PlayersLoaded) {
            return WidgetsBuild.buildPlayersList(
              players: state.players,
              onToggleOverlay: _toggleOverlay,
            );
          } else if (state is PlayersError) {
            return Center(child: Text('Erro: ${state.message}'));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildBottomSection() {
    return BlocBuilder<PlayersBloc, PlayersState>(builder: (context, state) {

        final bool canStart = state is PlayersLoaded && state.players.isNotEmpty;

        return Column(
          children: [
            WidgetsBuild.buildStartGameButton(
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
