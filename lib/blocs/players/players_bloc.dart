import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/players/players_event.dart';
import 'package:jogoteca/blocs/players/players_state.dart';

import '../../service/firebase_service.dart';

class PlayersBloc extends Bloc<PlayersEvent, PlayersState> {
  final FirebaseService service;

  PlayersBloc(this.service) : super(PlayersInitial()) {
    on<LoadPlayers>((event, emit) async {
      emit(PlayersLoading());
      try {
        final lista = await service.loadPlayers(event.partidaId);
        emit(PlayersLoaded(lista));
      } catch (e) {
        emit(PlayersError(e.toString()));
      }
    });

    on<AddPlayer>((event, emit) async {
      try {
        await service.addPlayer(event.partidaId, event.nome, event.pin, event.indice);
        add(LoadPlayers(event.partidaId));
      } catch (e) {
        emit(PlayersError(e.toString()));
      }
    });

    on<AddPlayerData>((event, emit) async {
      try {
        await service.addPlayerData(
          event.partidaId,
          event.jogadorId,
          event.pergunta,
          event.resposta,
          event.superAnonimo,
          event.perguntaSuperAnonimo,
          event.respostaSuperAnonimo,
        );
        add(LoadPlayers(event.partidaId));
      } catch (e) {
        emit(PlayersError(e.toString()));
      }
    });

    on<RemovePlayer>((event, emit) async {
      try {
        await service.removePlayer(event.partidaId, event.jogadorId);
        add(LoadPlayers(event.partidaId));
      } catch (e) {
        emit(PlayersError(e.toString()));
      }
    });

    on<LoadDirectMessages>((event, emit) async {
      try {
        final jogadores = await service.loadPlayers(event.partidaId);
        final mensagens = await service.loadDirectMessages(event.partidaId, event.jogadorId);
        emit(PlayersLoadedWithMessages(jogadores, mensagens));
      } catch (e) {
        emit(PlayersError(e.toString()));
      }
    });

    on<LoadResults>((event, emit) async {
      emit(ResultsLoading());
      try {
        final resultados = await service.loadResultsOptimized(event.partidaId);
        emit(ResultsLoaded(resultados));
      } catch (e) {
        emit(PlayersError(e.toString()));
      }
    });

    on<SendDirectMessage>((event, emit) async {
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
        emit(PlayersError(e.toString()));
      }
    });

    on<MarkMessageAsRead>((event, emit) async {
      try {
        await service.markMessageAsRead(event.partidaId, event.jogadorId, event.messageId);
      } catch (e) {
        emit(PlayersError(e.toString()));
      }
    });

    on<MarkAllMessagesAsRead>((event, emit) async {
      try {
        await service.markAllMessagesAsRead(event.partidaId, event.jogadorId);
      } catch (e) {
        emit(PlayersError(e.toString()));
      }
    });
  }
}