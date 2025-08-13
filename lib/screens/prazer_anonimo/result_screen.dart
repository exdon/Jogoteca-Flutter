import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/players/players_bloc.dart';
import '../../blocs/players/players_event.dart';
import '../../blocs/players/players_state.dart';
import '../../blocs/questions/questions_bloc.dart';
import '../../blocs/questions/questions_event.dart';
import '../../service/firebase_service.dart';
import '../../widget/app_bar_game.dart';
import 'game_screen.dart';

class ResultScreen extends StatefulWidget {
  final String partidaId;

  const ResultScreen({
    super.key,
    required this.partidaId
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {

  void _playAgain() {
    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<PlayersBloc>()),
              BlocProvider(
                create: (_) => QuestionsBloc(FirebaseService())..add(LoadQuestions()),
              ),
            ],
            child: GameScreen(partidaId: widget.partidaId),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        _showSnackMessage('Erro ao iniciar jogo: $e');
      }
    }
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => BlocProvider.value(
    //       value: context.read<PlayersBloc>(),
    //       child: GameScreen(partidaId: widget.partidaId),
    //     ),
    //   ),
    // );
  }

  void _showSnackMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Dispara o carregamento assim que a tela é criada
    context.read<PlayersBloc>().add(LoadResults(widget.partidaId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarGame(),
      body: BlocBuilder<PlayersBloc, PlayersState>(
        builder: (context, state) {
          if (state is ResultsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ResultsLoaded) {
            if (state.results.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhum resultado encontrado',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.results.length + 1, // +1 para o botão final
              itemBuilder: (context, index) {
                if (index == state.results.length) {
                  // Botão "Jogar nova partida"
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text(
                          'Jogar nova partida',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: _playAgain,
                      ),
                    ),
                  );
                }

                final item = state.results[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pergunta: ${item['pergunta']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Resposta: ${item['resposta']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          if (state is PlayersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Erro: ${state.message}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<PlayersBloc>()
                          .add(LoadResults(widget.partidaId));
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Carregando resultados...'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<PlayersBloc>().add(LoadResults(widget.partidaId));
        },
        tooltip: 'Recarregar resultados',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
