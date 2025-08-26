import 'package:jogoteca/data/home/home_games.dart';
import 'package:jogoteca/models/home/home_model.dart';

class HomeData {
  static final List<HomeModel> carouselGames = [
    HomeGames.prazerAnonimo,
    HomeGames.voceMeConhece,
    HomeGames.respondaOuPague,
    HomeGames.contraOTempo,
  ];

  static final List<CategoryModel> categories = [
    CategoryModel(
      titulo: '🚀 Jogos em alta',
      jogos: [
        HomeGames.prazerAnonimo,
        HomeGames.voceMeConhece,
        HomeGames.respondaOuPague,
        HomeGames.contraOTempo,
        HomeGames.jogo4,
        HomeGames.jogo5,
      ],
    ),
    CategoryModel(
      titulo: '⭐ Recomendados para você',
      jogos: [
        HomeGames.prazerAnonimo,
        HomeGames.jogo4,
      ],
    ),
  ];
}
