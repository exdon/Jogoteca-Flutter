import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/responda_ou_pague/challenges/challenges_event_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/challenges/challenges_state_rp.dart';
import 'package:jogoteca/service/responda_ou_pague/responsa_ou_pague_service.dart';


class ChallengesBlocRP extends Bloc<ChallengesEventRP, ChallengesStateRP> {
  final ResponsaOuPagueService service;

  ChallengesBlocRP(this.service) : super(ChallengeInitialRP()) {

    on<LoadChallengeRP>((event, emit) async {
      emit(ChallengeLoadingRP());
      try {
        final challenge = await service.loadChallenge(
            event.classificacao,
            event.completedChallenges,
            event.recentChallenges
        );
        emit(ChallengeLoadedRP(challenge));
      } catch (e) {
        emit(ChallengeErrorRP(e.toString()));
      }
    });

    on<ResetChallengeRP>((event, emit) => emit(ChallengeInitialRP()));
  }
}