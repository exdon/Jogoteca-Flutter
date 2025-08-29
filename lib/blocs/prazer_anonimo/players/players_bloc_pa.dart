import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/prazer_anonimo/players/players_event_pa.dart';
import 'package:jogoteca/blocs/prazer_anonimo/players/players_state_pa.dart';
import 'package:jogoteca/service/prazer_anonimo/prazer_anonimo_service.dart';

class PlayersBlocPA extends Bloc<PlayersEventPA, PlayersStatePA> {
  final PrazerAnonimoService service;

  PlayersBlocPA(this.service) : super(PlayersInitialPA()) {
    on<LoadPlayersPA>((event, emit) async {
      emit(PlayersLoadingPA());
      try {
        final lista = await service.loadPlayers(event.partidaId);
        emit(PlayersLoadedPA(lista));
      } catch (e) {
        emit(PlayersErrorPA(e.toString()));
      }
    });

    on<AddPlayerPA>((event, emit) async {
      try {
        await service.addPlayer(event.partidaId, event.nome, event.pin, event.indice);
        add(LoadPlayersPA(event.partidaId));
      } catch (e) {
        emit(PlayersErrorPA(e.toString()));
      }
    });

    on<AddPlayerDataPA>((event, emit) async {
      try {
        await service.addPlayerData(
          event.partidaId,
          event.jogadorId,
          event.pergunta,
          event.resposta,
          event.superAnonimo,
          event.perguntaSuperAnonimo,
          event.respostaSuperAnonimo,
          event.detalhesSuperAnonimo,
        );
        add(LoadPlayersPA(event.partidaId));
      } catch (e) {
        emit(PlayersErrorPA(e.toString()));
      }
    });

    on<RemovePlayerPA>((event, emit) async {
      try {
        await service.removePlayer(event.partidaId, event.jogadorId);
        add(LoadPlayersPA(event.partidaId));
      } catch (e) {
        emit(PlayersErrorPA(e.toString()));
      }
    });

    on<LoadDirectMessagesPA>((event, emit) async {
      try {
        final jogadores = await service.loadPlayers(event.partidaId);
        final mensagens = await service.loadDirectMessages(event.partidaId, event.jogadorId);
        final saQuestions = await service.loadSuperAnonimoQuestions(event.partidaId, event.jogadorId);
        emit(PlayersLoadedWithMessagesAndSA(jogadores, mensagens, saQuestions));
      } catch (e) {
        emit(PlayersErrorPA(e.toString()));
      }
    });

    on<LoadResultsPA>((event, emit) async {
      emit(ResultsLoadingPA());
      try {
        final resultados = await service.loadResultsOptimized(event.partidaId);
        emit(ResultsLoadedPA(resultados));
      } catch (e) {
        emit(PlayersErrorPA(e.toString()));
      }
    });

    on<SendDirectMessagePA>((event, emit) async {
      try {
        // Busca o nome do remetente
        final jogadores = await service.loadPlayers(event.partidaId);
        final remetente = jogadores.firstWhere((j) => j['id'] == event.remetenteId);
        final remetenteNome = remetente['nome'];

        await service.sendDirectMessage(
          event.partidaId,
          event.remetenteId,
          event.destinatarioId,
          event.mensagem,
          remetenteNome,
        );
      } catch (e) {
        emit(PlayersErrorPA(e.toString()));
      }
    });

    on<MarkMessageAsReadPA>((event, emit) async {
      try {
        await service.markMessageAsRead(event.partidaId, event.jogadorId, event.messageId);
      } catch (e) {
        emit(PlayersErrorPA(e.toString()));
      }
    });

    on<MarkAllMessagesAsReadPA>((event, emit) async {
      try {
        await service.markAllMessagesAsRead(event.partidaId, event.jogadorId);
      } catch (e) {
        emit(PlayersErrorPA(e.toString()));
      }
    });

    on<LoadInboxPA>((event, emit) async {
      try {
        final jogadores = await service.loadPlayers(event.partidaId);
        final mensagens = await service.loadDirectMessages(event.partidaId, event.jogadorId);
        final saQuestions = await service.loadSuperAnonimoQuestions(event.partidaId, event.jogadorId);
        emit(PlayersLoadedWithMessagesAndSA(jogadores, mensagens, saQuestions));
      } catch (e) {
        emit(PlayersErrorPA(e.toString()));
      }
    });

    on<SendSuperAnonimoQuestionPA>((event, emit) async {
      try {
        // Busca o nome do remetente
        final jogadores = await service.loadPlayers(event.partidaId);
        final remetente = jogadores.firstWhere((j) => j['id'] == event.remetenteId);
        final remetenteNome = remetente['nome'];

        await service.sendSuperAnonimoQuestion(
          event.partidaId,
          event.remetenteId,
          event.destinatarioId,
          event.pergunta,
          remetenteNome,
        );
      } catch (e) {
        emit(PlayersErrorPA(e.toString()));
      }
    });

    on<AnswerSuperAnonimoQuestionPA>((event, emit) async {
      try {
        await service.answerSuperAnonimoQuestion(
          event.partidaId,
          event.jogadorId,
          event.questionId,
          event.resposta,
        );
        // Opcional: recarregar inbox após responder
        final jogadores = await service.loadPlayers(event.partidaId);
        final mensagens = await service.loadDirectMessages(event.partidaId, event.jogadorId);
        final saQuestions = await service.loadSuperAnonimoQuestions(event.partidaId, event.jogadorId);
        emit(PlayersLoadedWithMessagesAndSA(jogadores, mensagens, saQuestions));
      } catch (e) {
        emit(PlayersErrorPA(e.toString()));
      }
    });

    on<SendSuperAnonimoChallengePA>((event, emit) async {
      try {
        // Busca o nome do remetente
        final jogadores = await service.loadPlayers(event.partidaId);
        final remetente = jogadores.firstWhere((j) => j['id'] == event.remetenteId);
        final remetenteNome = remetente['nome'];

        await service.sendSuperAnonimoChallenge(
          event.partidaId,
          event.remetenteId,
          event.destinatarioId,
          event.desafio,
          remetenteNome,
        );
      } catch (e) {
        emit(PlayersErrorPA(e.toString()));
      }
    });

    on<MarkChallengeAsCompletedPA>((event, emit) async {
      try {
        await service.markChallengeAsCompleted(event.partidaId, event.jogadorId, event.challengeId);
      } catch (e) {
        emit(PlayersErrorPA(e.toString()));
      }
    });
  }
}