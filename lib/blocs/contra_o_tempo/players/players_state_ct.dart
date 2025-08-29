abstract class PlayersStateCT {}
class PlayersInitialCT extends PlayersStateCT {}
class PlayersLoadingCT extends PlayersStateCT {}
class PlayersLoadedCT extends PlayersStateCT {
  final List<Map<String, dynamic>> players;
  PlayersLoadedCT(this.players);
}
class PlayersErrorCT extends PlayersStateCT {
  final String message;
  PlayersErrorCT(this.message);
}
