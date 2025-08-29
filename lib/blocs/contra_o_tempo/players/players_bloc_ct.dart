import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/contra_o_tempo/players/players_event_ct.dart';
import 'package:jogoteca/blocs/contra_o_tempo/players/players_state_ct.dart';
import 'package:jogoteca/service/contra_o_tempo/contra_o_tempo_service.dart';


class PlayersBlocCT extends Bloc<PlayersEventCT, PlayersStateCT> {
  final ContraOTempoService service;

  PlayersBlocCT(this.service) : super(PlayersInitialCT()) {
    on<LoadPlayersCT>((event, emit) async {
      emit(PlayersLoadingCT());
      try {
        final lista = await service.loadPlayers(event.partidaId);
        emit(PlayersLoadedCT(lista));
      } catch (e) {
        emit(PlayersErrorCT(e.toString()));
      }
    });

    on<AddPlayerCT>((event, emit) async {
      try {
        await service.addPlayer(event.partidaId, event.nome, event.indice);
        add(LoadPlayersCT(event.partidaId));
      } catch (e) {
        emit(PlayersErrorCT(e.toString()));
      }
    });
  }
}