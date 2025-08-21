import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/models/home/home_model.dart';
import 'package:jogoteca/screens/app_em_construcao_screen.dart';
import 'package:jogoteca/screens/prazer_anonimo/rules/rules_screen.dart';

class HomeGames {
  static const prazerAnonimo = HomeModel(
    nome: 'Prazer, Anônimo!',
    imagem: AppConstants.prazerAnonimoImage,
    target: RulesScreen(),
    alert: true,
  );

  static const voceMeConhece = HomeModel(
    nome: 'Você me Conhece?',
    imagem: AppConstants.defaultGameImage,
    target: AppEmConstrucaoScreen(),
  );

  static const respondaOuPague = HomeModel(
    nome: 'Responda ou Pague',
    imagem: AppConstants.defaultGameImage,
    target: AppEmConstrucaoScreen(),
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
