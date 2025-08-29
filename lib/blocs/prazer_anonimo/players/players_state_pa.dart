abstract class PlayersStatePA {}
class PlayersInitialPA extends PlayersStatePA {}
class PlayersLoadingPA extends PlayersStatePA {}
class PlayersLoadedPA extends PlayersStatePA {
  final List<Map<String, dynamic>> players;
  PlayersLoadedPA(this.players);
}
class PlayersErrorPA extends PlayersStatePA {
  final String message;
  PlayersErrorPA(this.message);
}
class PlayersLoadedWithMessagesPA extends PlayersStatePA {
  final List<Map<String, dynamic>> players;
  final List<Map<String, dynamic>> directMessages;

  PlayersLoadedWithMessagesPA(this.players, this.directMessages);
}
class ResultsLoadingPA extends PlayersStatePA {}
class ResultsLoadedPA extends PlayersStatePA {
  final List<Map<String, dynamic>> results;

  ResultsLoadedPA(this.results);
}
class PlayersLoadedWithMessagesAndSA extends PlayersStatePA {
  final List<Map<String, dynamic>> players;
  final List<Map<String, dynamic>> directMessages;
  final List<Map<String, dynamic>> superAnonimoQuestions;

  PlayersLoadedWithMessagesAndSA(this.players, this.directMessages, this.superAnonimoQuestions);
}