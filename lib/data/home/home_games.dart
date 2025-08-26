import 'package:jogoteca/blocs/players/players_bloc.dart';
import 'package:jogoteca/blocs/responda_ou_pague/players/players_bloc_rp.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/constants/prazer_anonimo/rules_constants.dart';
import 'package:jogoteca/constants/responda_ou_pague/rules_constants_rp.dart';
import 'package:jogoteca/models/home/home_model.dart';
import 'package:jogoteca/screens/app_em_construcao_screen.dart';
import 'package:jogoteca/screens/prazer_anonimo/add_players/add_players_screen.dart';
import 'package:jogoteca/screens/responda_ou_pague/add_players/add_players_rp_screen.dart';
import 'package:jogoteca/screens/rules_screen.dart';
import 'package:jogoteca/service/firebase_service.dart';
import 'package:jogoteca/service/responda_ou_pague/responsa_ou_pague_service.dart';

class HomeGames {
  static final prazerAnonimo = HomeModel(
    nome: 'Prazer, Anônimo!',
    imagem: AppConstants.prazerAnonimoImage,
    target: RulesScreen(
      backgroundImagePath: AppConstants.backgroundPrazerAnonimo,
      rulesText: RulesConstants.rulesText,
      bloc: PlayersBloc(FirebaseService()),
      destinationBuilder: (partidaId, bloc) => AddPlayersScreen(partidaId: partidaId),
    ),
    alert: true,
  );

  static const voceMeConhece = HomeModel(
    nome: 'Você me Conhece?',
    imagem: AppConstants.defaultGameImage,
    target: AppEmConstrucaoScreen(),
  );

  static final respondaOuPague = HomeModel(
    nome: 'Responda ou Pague',
    imagem: AppConstants.respondaOuPagueImage,
    target: RulesScreen(
      backgroundImagePath: AppConstants.backgroundRespondaOuPague,
      rulesText: RulesConstantsRP.rulesText,
      bloc: PlayersBlocRP(ResponsaOuPagueService()),
      destinationBuilder: (partidaId, bloc) => AddPlayersRPScreen(partidaId: partidaId),
    ),
    alert: true
  );

  static const contraOTempo = HomeModel(
    nome: 'Contra o Tempo',
    imagem: AppConstants.defaultGameImage,
    target: AppEmConstrucaoScreen(),
  );

  static const jogo4 = HomeModel(
    nome: 'Jogo 4',
    imagem: AppConstants.defaultGameImage,
    target: AppEmConstrucaoScreen(),
  );

  static const jogo5 = HomeModel(
    nome: 'Jogo 5',
    imagem: AppConstants.defaultGameImage,
    target: AppEmConstrucaoScreen(),
  );
}
