import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/responda_ou_pague/players/players_event_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/players/players_state_rp.dart';
import 'package:jogoteca/service/responda_ou_pague/responsa_ou_pague_service.dart';


class PlayersBlocRP extends Bloc<PlayersEventRP, PlayersStateRP> {
  final ResponsaOuPagueService service;

  PlayersBlocRP(this.service) : super(PlayersInitialRP()) {
    on<LoadPlayersRP>((event, emit) async {
      emit(PlayersLoadingRP());
      try {
        final lista = await service.loadPlayers(event.partidaId);
        emit(PlayersLoadedRP(lista));
      } catch (e) {
        emit(PlayersErrorRP(e.toString()));
      }
    });

    on<LoadRandomPlayerRP>((event, emit) async {
      emit(PlayersLoadingRP());
      try {
        final lista = await service.loadPlayers(event.partidaId);
        final random = Random();
        final index = random.nextInt(lista.length);
        final player = lista[index];

        final playerName = player['nome'];
        final playerId = player['id'];

        emit(RandomPlayerLoadedRP(playerName, playerId));
      } catch (e) {
        emit(PlayersErrorRP(e.toString()));
      }
    });

    on<LoadPlayerDataRP>((event, emit) async {
      emit(PlayersLoadingRP());
      try {
        final playerData = await service.loadPlayerData(event.partidaId, event.jogadorId);
        if (playerData != null) {
          emit(PlayerDataLoadedRP(playerData));
        } else {
          emit(PlayersErrorRP('Jogador com id: ${event.jogadorId} não foi encontrado'));
        }
      } catch (e) {
        emit(PlayersErrorRP(e.toString()));
      }
    });

    on<AddPlayerRP>((event, emit) async {
      try {
        await service.addPlayer(event.partidaId, event.nome);
        add(LoadPlayersRP(event.partidaId));
      } catch (e) {
        emit(PlayersErrorRP(e.toString()));
      }
    });

    on<UpdatePlayerDataRP>((event, emit) async {
      try {
        await service.updatePlayerData(event.partidaId, event.jogadorId, event.vidas);
        add(LoadPlayersRP(event.partidaId));
      } catch (e) {
        emit(PlayersErrorRP(e.toString()));
      }
    });
  }
}