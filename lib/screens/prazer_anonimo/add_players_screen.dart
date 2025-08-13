import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../blocs/players/players_bloc.dart';
import '../../blocs/players/players_event.dart';
import '../../blocs/players/players_state.dart';
import '../../blocs/questions/questions_bloc.dart';
import '../../blocs/questions/questions_event.dart';
import '../../service/firebase_service.dart';
import '../../widget/hacker_transition_screen.dart';
import '../../widget/app_bar_game.dart';
import 'game_screen.dart';

class AddPlayersScreen extends StatefulWidget {
  final String partidaId;

  const AddPlayersScreen({super.key, required this.partidaId});

  @override
  State<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {

  bool isAdding = false;
  bool _isNavigating = false;

  final _nomeController = TextEditingController();
  final _pinController = TextEditingController();

  OverlayEntry? _overlayEntry;

  String nomeJogador = '';
  int jogadorIndice = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<PlayersBloc>();
      if (!bloc.isClosed) {
        bloc.add(LoadPlayers(widget.partidaId));
      }
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  bool _isPinValid(String pin) {
    final pinReg = RegExp(r'^\d{4,6}$');
    return pinReg.hasMatch(pin);
  }

  void _savePlayer() {
    if (!mounted) return;

    final nome = _nomeController.text.trim();
    final pin = _pinController.text.trim();

    nomeJogador = nome;

    setState(() {
      jogadorIndice++;
    });

    if (nome.isEmpty) {
      _showSnackMessage('Por favor, insira o nome do jogador');
      return;
    }
    if (!_isPinValid(pin)) {
      _showSnackMessage('Pin deve ter entre 4 e 6 dígitos numéricos');
      return;
    }

    final bloc = context.read<PlayersBloc>();
    if (!bloc.isClosed) {
      bloc.add(
        AddPlayer(widget.partidaId, jogadorIndice, nome, int.parse(pin)),
      );
    }

    setState(() {
      isAdding = false;
      _resetTextFields();
    });
  }

  void _resetTextFields() {
    _nomeController.clear();
    _pinController.clear();
  }

  void _showSnackMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _startGame() {
    if (_isNavigating || !mounted) return;

    setState(() {
      _isNavigating = true;
    });

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
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
        _showSnackMessage('Erro ao iniciar jogo: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarGame(),
      body: BlocListener<PlayersBloc, PlayersState>(listener: (context, state) {
        if (state is PlayersError) {
          _showSnackMessage('Erro ao adicionar jogador(a) $nomeJogador: ${state.message}');
        } else if (state is PlayersLoaded && !isAdding) {
          if (state.players.isNotEmpty) _showSnackMessage('Jogador(a) $nomeJogador adicionado com sucesso!');
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
              child: Column(
                children: [
                  isAdding ? _buildPlayerFields() : _buildAddButton(),
                  const SizedBox(height: 24),
                  _buildPlayersList(),
                  const SizedBox(height: 12),
                  _buildStartGameButton(),
                  const SizedBox(height: 54),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: _isNavigating ? null : () => setState(() => isAdding = true),
      icon: const FaIcon(FontAwesomeIcons.userPlus, color: Colors.black),
      label: const Text(
        'Adicionar jogador',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      return;
    }

    final screenSize = MediaQuery.of(context).size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: screenSize.height / 2 - 100,
        left: screenSize.width / 2 - 125,
        child: Material(
          elevation: 8,
          color: Colors.transparent,
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Por que adicionar jogadores?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Isso permite personalizar a experiência e registrar respostas individuais.',
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                    },
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildPlayerFields() {
    return Column(
      children: [
        TextField(
          controller: _nomeController,
          enabled: !_isNavigating,
          decoration: InputDecoration(
            labelText: 'Nome do jogador',
            labelStyle: const TextStyle(color: Colors.white),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightGreen),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                _resetTextFields();
                setState(() => isAdding = false);
              },
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.green,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _pinController,
          enabled: !_isNavigating,
          decoration: InputDecoration(
            labelText: 'PIN (4-6 dígitos)',
            labelStyle: const TextStyle(color: Colors.white),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightGreen),
            ),
            counterStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                _resetTextFields();
                setState(() => isAdding = false);
              },
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          cursorColor: Colors.green,
          style: const TextStyle(color: Colors.white),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _savePlayer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white70,
            foregroundColor: Colors.black,
          ),
          child: _isNavigating
              ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 15),
              Text('Iniciando...', style: TextStyle(fontSize: 18)),
            ],
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_kabaddi, size: 24),
              SizedBox(width: 15),
              Text('Salvar Jogador', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersList() {
    return Expanded(
      child: BlocBuilder<PlayersBloc, PlayersState>(
        builder: (context, state) {
          if (state is PlayersLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is PlayersLoaded) {
            final players = state.players;

            if (players.isEmpty) {
              return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Nenhum jogador cadastrado',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                        ),
                      ),
                      Text(
                        'Adicione jogadores para iniciar o jogo',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 16
                        ),
                      ),
                      const SizedBox(height: 80),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.info_outline, color: Colors.white),
                            tooltip: 'Mais informações',
                            onPressed: _toggleOverlay,
                          ),
                          Expanded(
                              child: GestureDetector(
                                onTap: _toggleOverlay,
                                child: Card(
                                  color: Colors.white10,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      'Por que devo adicionar jogadores?',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                          ),
                        ],
                      )
                    ],
                  )
              );
            }
            return Stack(
              children: [
                const Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                      'Jogadores:',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                      ),
                  ),
                ),
                ListView.builder(
                itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return ListTile(
                      leading: const Icon(FontAwesomeIcons.userNinja, color: Colors.white),
                      title: Text(player['nome'], style: const TextStyle(color: Colors.white)),
                    );
                  },
                ),
              ],
            );
          } else if (state is PlayersError) {
            return Center(child: Text('Erro: ${state.message}'));
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildStartGameButton() {
    return BlocBuilder<PlayersBloc, PlayersState>(
      builder: (context, state) {
        final bool canStart = state is PlayersLoaded &&
            state.players.isNotEmpty &&
            !_isNavigating;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: canStart ? _startGame : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canStart ? Colors.white70 : Colors.grey,
              foregroundColor: canStart ? Colors.black : Colors.white54,
            ),
            child: _isNavigating
                ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 15),
                Text('Iniciando...', style: TextStyle(fontSize: 18)),
              ],
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.dice),
                SizedBox(width: 15),
                Text('Iniciar Jogo', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        );
      },
    );
  }
}
