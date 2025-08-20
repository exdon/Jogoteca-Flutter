// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../blocs/players/players_bloc.dart';
// import '../../blocs/players/players_event.dart';
// import '../../blocs/players/players_state.dart';
// import '../../widget/app_bar_game.dart';
// import '../../widget/hacker_transition_screen.dart';
// import 'add_players_validator.dart';
// import 'add_players_widgets.dart';
//
// class AddPlayersScreen extends StatefulWidget {
//   final String partidaId;
//
//   const AddPlayersScreen({super.key, required this.partidaId});
//
//   @override
//   State<AddPlayersScreen> createState() => _AddPlayersScreenState();
// }
//
// class _AddPlayersScreenState extends State<AddPlayersScreen> {
//   bool isAdding = false;
//   bool _isNavigating = false;
//
//   final _nomeController = TextEditingController();
//   final _pinController = TextEditingController();
//
//   OverlayEntry? _overlayEntry;
//
//   String nomeJogador = '';
//   int jogadorIndice = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final bloc = context.read<PlayersBloc>();
//       if (!bloc.isClosed) {
//         bloc.add(LoadPlayers(widget.partidaId));
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _nomeController.dispose();
//     _pinController.dispose();
//     _overlayEntry?.remove();
//     super.dispose();
//   }
//
//   void _savePlayer() {
//     if (!mounted) return;
//
//     final nome = _nomeController.text.trim();
//     final pin = _pinController.text.trim();
//
//     nomeJogador = nome;
//
//     setState(() {
//       jogadorIndice++;
//     });
//
//     final validation = AddPlayersValidator.validatePlayerData(nome, pin);
//
//     if (validation['nome'] != null) {
//       _showSnackMessage(validation['nome']!);
//       return;
//     }
//
//     if (validation['pin'] != null) {
//       _showSnackMessage(validation['pin']!);
//       return;
//     }
//
//     final bloc = context.read<PlayersBloc>();
//     if (!bloc.isClosed) {
//       bloc.add(
//         AddPlayer(widget.partidaId, jogadorIndice, nome, int.parse(pin)),
//       );
//     }
//
//     setState(() {
//       isAdding = false;
//       _resetTextFields();
//     });
//   }
//
//   void _resetTextFields() {
//     _nomeController.clear();
//     _pinController.clear();
//   }
//
//   void _showSnackMessage(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }
//
//   void _startGame() {
//     if (_isNavigating || !mounted) return;
//
//     setState(() {
//       _isNavigating = true;
//     });
//
//     try {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => HackerTransitionScreen(
//             partidaId: widget.partidaId,
//             playersBloc: context.read<PlayersBloc>(),
//           ),
//         ),
//       );
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isNavigating = false;
//         });
//         _showSnackMessage('Erro ao iniciar jogo: $e');
//       }
//     }
//   }
//
//   void _toggleOverlay() {
//     if (_overlayEntry != null) {
//       _overlayEntry!.remove();
//       _overlayEntry = null;
//       return;
//     }
//
//     _overlayEntry = AddPlayersWidgets.createInfoOverlay(
//       context: context,
//       onClose: () {
//         _overlayEntry?.remove();
//         _overlayEntry = null;
//       },
//     );
//
//     Overlay.of(context).insert(_overlayEntry!);
//   }
//
//   void _cancelAddingPlayer() {
//     _resetTextFields();
//     setState(() => isAdding = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBarGame(),
//       body: BlocListener<PlayersBloc, PlayersState>(
//         listener: (context, state) {
//           if (state is PlayersError) {
//             _showSnackMessage('Erro ao adicionar jogador(a) $nomeJogador: ${state.message}');
//           } else if (state is PlayersLoaded && !isAdding) {
//             if (state.players.isNotEmpty) {
//               _showSnackMessage('Jogador(a) $nomeJogador adicionado com sucesso!');
//             }
//           }
//         },
//         child: Stack(
//           children: [
//             // Fundo
//             Positioned.fill(
//               child: Image.asset("images/background_anonimo.jpg", fit: BoxFit.cover),
//             ),
//             // Overlay escuro
//             Positioned.fill(
//               child: Container(color: Colors.black.withOpacity(0.4)),
//             ),
//             Padding(
//               padding: EdgeInsets.only(
//                 top: kToolbarHeight + MediaQuery.of(context).padding.top + 50,
//                 left: 16,
//                 right: 16,
//                 bottom: 16,
//               ),
//               child: Column(
//                 children: [
//                   _buildTopSection(),
//                   const SizedBox(height: 24),
//                   _buildPlayersListSection(),
//                   const SizedBox(height: 12),
//                   _buildStartGameSection(),
//                   const SizedBox(height: 54),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTopSection() {
//     if (isAdding) {
//       return AddPlayersWidgets.buildPlayerFields(
//         nomeController: _nomeController,
//         pinController: _pinController,
//         isNavigating: _isNavigating,
//         onCancel: _cancelAddingPlayer,
//         onSave: _savePlayer,
//       );
//     } else {
//       return AddPlayersWidgets.buildAddButton(
//         isNavigating: _isNavigating,
//         onPressed: () => setState(() => isAdding = true),
//       );
//     }
//   }
//
//   Widget _buildPlayersListSection() {
//     return Expanded(
//       child: BlocBuilder<PlayersBloc, PlayersState>(
//         builder: (context, state) {
//           if (state is PlayersLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is PlayersLoaded) {
//             return AddPlayersWidgets.buildPlayersList(
//               players: state.players,
//               onToggleOverlay: _toggleOverlay,
//             );
//           } else if (state is PlayersError) {
//             return Center(child: Text('Erro: ${state.message}'));
//           } else {
//             return const SizedBox.shrink();
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildStartGameSection() {
//     return BlocBuilder<PlayersBloc, PlayersState>(
//       builder: (context, state) {
//         final bool canStart = state is PlayersLoaded &&
//             state.players.isNotEmpty &&
//             !_isNavigating;
//
//         return AddPlayersWidgets.buildStartGameButton(
//           canStart: canStart,
//           isNavigating: _isNavigating,
//           onPressed: canStart ? _startGame : null,
//         );
//       },
//     );
//   }
// }