import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/voce_me_conhece/players/players_event_vmc.dart';
import 'package:jogoteca/blocs/voce_me_conhece/players/players_state_vmc.dart';
import 'package:jogoteca/service/voce_me_conhece/voce_me_conhece_service.dart';

class PlayersBlocVMC extends Bloc<PlayersEventVMC, PlayersStateVMC> {
  final VoceMeConheceService service;

  PlayersBlocVMC(this.service) : super(PlayersInitialVMC()) {
    on<LoadPlayersVMC>((event, emit) async {
      emit(PlayersLoadingVMC());
      try {
        final lista = await service.loadPlayers(event.partidaId);
        emit(PlayersLoadedVMC(lista));
      } catch (e) {
        emit(PlayersErrorVMC(e.toString()));
      }
    });

    on<AddPlayerVMC>((event, emit) async {
      try {
        await service.addPlayer(event.partidaId, event.nome, event.indice);
        add(LoadPlayersVMC(event.partidaId));
      } catch (e) {
        emit(PlayersErrorVMC(e.toString()));
      }
    });

    on<LoadPlayerAnswerVMC>((event, emit) async {
      emit(PlayerAnswerLoadingVMC());
      try {
        final playerAnswer = await service.loadPlayerAnswer(event.partidaId, event.questionId, event.playerId);
        emit(PlayerAnswerLoadedVMC(playerAnswer));
      } catch (e) {
        emit(PlayersErrorVMC(e.toString()));
      }
    });

    on<UpdatePlayerStatsVMC>((event, emit) async {
      try {
        await service.updatePlayerStats(event.playerId, event.isCorrect);
      } catch (e) {
        emit(PlayersErrorVMC(e.toString()));
      }
    });

    on<ResetPlayerStatsVMC>((event, emit) async {
      try {
        await service.resetPlayerStats(event.playerId);
      } catch (e) {
        emit(PlayersErrorVMC(e.toString()));
      }
    });

    on<GetPlayerRankingVMC>((event, emit) async {
      emit(RankingLoadingVMC());
      try {
        final ranking = await service.getPlayerRanking(event.partidaId);
        emit(RankingLoadedVMC(ranking));
      } catch (e) {
        emit(PlayersErrorVMC(e.toString()));
      }
    });

    on<ClearAnsweredQuestionsVMC>((event, emit) async {
      try {
        await service.clearAnsweredQuestions(event.partidaId);
      } catch (e) {
        emit(PlayersErrorVMC(e.toString()));
      }
    });

    on<ResetGameVMC>((event, emit) async {
      try {
        await service.resetGame(event.partidaId);
        add(LoadPlayersVMC(event.partidaId));
      } catch (e) {
        emit(PlayersErrorVMC(e.toString()));
      }
    });

    // Manter compatibilidade com código antigo
    on<AddPlayerAnswerVMC>((event, emit) async {
      try {
        await service.addPlayerAnswer(event.partidaId, event.questionId, event.playerId, event.answer);
        add(LoadPlayerAnswerVMC(event.partidaId, event.questionId, event.playerId));
      } catch (e) {
        emit(PlayersErrorVMC(e.toString()));
      }
    });

    // Adicionar no construtor do PlayersBlocVMC:

    on<SavePlayerAnswerVMC>((event, emit) async {
      try {
        await service.savePlayerAnswer(
          partidaId: event.partidaId,
          questionId: event.questionId,
          playerId: event.playerId,
          answer: event.answer,
          opcoesFalsas: event.opcoesFalsas,
          isTrue: event.isTrue,
        );
        emit(PlayerAnswerSavedVMC());
      } catch (e) {
        emit(PlayersErrorVMC(e.toString()));
      }
    });

    on<GetPlayerAnswerVMC>((event, emit) async {
      emit(PlayerAnswerLoadingVMC());
      try {
        final playerAnswer = await service.getPlayerAnswer(
            event.partidaId,
            event.questionId,
            event.playerId
        );
        emit(SinglePlayerAnswerLoadedVMC(playerAnswer));
      } catch (e) {
        emit(PlayersErrorVMC(e.toString()));
      }
    });

    on<SavePlayerVoteVMC>((event, emit) async {
      try {
        await service.savePlayerVote(
          partidaId: event.partidaId,
          questionId: event.questionId,
          jogadorRespondentId: event.jogadorRespondentId,
          jogadorVotanteId: event.jogadorVotanteId,
          voto: event.voto,
          acertou: event.acertou,
        );
      } catch (e) {
        emit(PlayersErrorVMC(e.toString()));
      }
    });

    on<GetVotesForQuestionVMC>((event, emit) async {
      emit(VotesLoadingVMC());
      try {
        final votes = await service.getVotesForQuestion(
          event.partidaId,
          event.questionId,
          event.jogadorRespondentId,
        );
        emit(VotesLoadedVMC(votes));
      } catch (e) {
        emit(PlayersErrorVMC(e.toString()));
      }
    });

    on<ResetAllPlayersStatsVMC>((event, emit) async {
      try {
        await service.resetAllPlayersStats(event.partidaId);
      } catch (e) {
        emit(PlayersErrorVMC(e.toString()));
      }
    });

    on<ResetCompleteGameVMC>((event, emit) async {
      try {
        await service.resetCompleteGame(event.partidaId);
        add(LoadPlayersVMC(event.partidaId));
      } catch (e) {
        emit(PlayersErrorVMC(e.toString()));
      }
    });

  }
}