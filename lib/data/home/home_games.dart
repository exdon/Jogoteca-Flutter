
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:jogoteca/blocs/contra_o_tempo/players/players_bloc_ct.dart';
import 'package:jogoteca/blocs/prazer_anonimo/players/players_bloc_pa.dart';
import 'package:jogoteca/blocs/responda_ou_pague/players/players_bloc_rp.dart';
import 'package:jogoteca/blocs/voce_me_conhece/players/players_bloc_vmc.dart';
import 'package:jogoteca/constants/alfabeto_insano/rules_constants_ai.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/constants/contra_o_tempo/rules_constants_ct.dart';
import 'package:jogoteca/constants/prazer_anonimo/rules_constants.dart';
import 'package:jogoteca/constants/responda_ou_pague/rules_constants_rp.dart';
import 'package:jogoteca/constants/voce_me_conhece/rules_constants_vmc.dart';
import 'package:jogoteca/models/home/home_model.dart';
import 'package:jogoteca/screens/alfabeto_insano/game/alfabeto_insano_setup_screen.dart';
import 'package:jogoteca/screens/app_em_construcao_screen.dart';
import 'package:jogoteca/screens/contra_o_tempo/add_players/add_players_ct_screen.dart';
import 'package:jogoteca/screens/prazer_anonimo/add_players/add_players_pa_screen.dart';
import 'package:jogoteca/screens/responda_ou_pague/add_players/add_players_rp_screen.dart';
import 'package:jogoteca/screens/rules_screen.dart';
import 'package:jogoteca/screens/voce_me_conhece/add_players/add_players_vmc_screen.dart';
import 'package:jogoteca/service/contra_o_tempo/contra_o_tempo_service.dart';
import 'package:jogoteca/service/prazer_anonimo/prazer_anonimo_service.dart';
import 'package:jogoteca/service/responda_ou_pague/responsa_ou_pague_service.dart';
import 'package:jogoteca/service/voce_me_conhece/voce_me_conhece_service.dart';

class HomeGames {
  static final prazerAnonimo = HomeModel(
    nome: 'Prazer, Anônimo!',
    imagem: AppConstants.prazerAnonimoImage,
    target: RulesScreen(
      backgroundImagePath: AppConstants.backgroundPrazerAnonimo,
      rulesText: RulesConstants.rulesText,
      bloc: PlayersBlocPA(PrazerAnonimoService()),
      destinationBuilder: (partidaId, bloc) => AddPlayersPAScreen(partidaId: partidaId),
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
        ),
        strong: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
        blockquote: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue[200],
        ),
        blockquotePadding: EdgeInsets.all(12),
        blockquoteDecoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
        ),
        h1: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.amber,
        ),
      ),
    ),
    alert: true,
  );

  static final voceMeConhece = HomeModel(
    nome: 'Você me Conhece?',
    imagem: AppConstants.voceMeConheceImage,
    target: RulesScreen(
      backgroundImagePath: AppConstants.backgroundVoceMeConhece,
      rulesText: RulesConstantsVMC.rulesText,
      bloc: PlayersBlocVMC(VoceMeConheceService()),
      destinationBuilder: (partidaId, bloc) => AddPlayersVMCScreen(partidaId: partidaId),
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
        ),
        strong: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        blockquote: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue[200],
        ),
        blockquotePadding: EdgeInsets.all(12),
        blockquoteDecoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
        ),
        h1: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    ),
  );

  static final respondaOuPague = HomeModel(
    nome: 'Responda ou Pague',
    imagem: AppConstants.respondaOuPagueImage,
    target: RulesScreen(
      backgroundImagePath: AppConstants.backgroundRespondaOuPague,
      rulesText: RulesConstantsRP.rulesText,
      bloc: PlayersBlocRP(ResponsaOuPagueService()),
      destinationBuilder: (partidaId, bloc) => AddPlayersRPScreen(partidaId: partidaId),
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
        ),
        strong: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
        h1: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrange,
        ),
        h2: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.brown,
        ),
      ),
    ),
    alert: true
  );

  static final contraOTempo = HomeModel(
    nome: 'Contra o Tempo',
    imagem: AppConstants.contraOTempoImage,
    target: RulesScreen(
      backgroundImagePath: AppConstants.backgroundContraOTempo,
      rulesText: RulesConstantsCT.rulesText,
      bloc: PlayersBlocCT(ContraOTempoService()),
      destinationBuilder: (partidaId, bloc) => AddPlayersCTScreen(partidaId: partidaId),
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
        ),
        strong: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
        h1: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    ),
  );

  static final alfabetoInsano = HomeModel(
    nome: 'Alfabeto Insano',
    imagem: AppConstants.alfabetoInsanoImage,
    target: RulesScreen(
        backgroundImagePath: AppConstants.backgroundAlfabetoInsano,
        rulesText: RulesConstantsAI.rulesText,
        bloc: PlayersBlocCT(ContraOTempoService()),
        destinationBuilder: (partidaId, bloc) => AlfabetoInsanoSetupScreen(),
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.5,
          ),
          strong: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
          h1: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          h2: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
          h3: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFfa0710),
          ),
        ),
    ),
  );

  static const jogo5 = HomeModel(
    nome: 'Jogo 5',
    imagem: AppConstants.defaultGameImage,
    target: AppEmConstrucaoScreen(),
  );
}
