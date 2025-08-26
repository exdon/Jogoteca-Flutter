abstract class PlayersStateRP {}
class PlayersInitialRP extends PlayersStateRP {}
class PlayersLoadingRP extends PlayersStateRP {}
class PlayersLoadedRP extends PlayersStateRP {
  final List<Map<String, dynamic>> players;
  PlayersLoadedRP(this.players);
}
class RandomPlayerLoadedRP extends PlayersStateRP {
  final String playerName;
  final String playerId;
  RandomPlayerLoadedRP(this.playerName, this.playerId);
}
class PlayerDataLoadedRP extends PlayersStateRP {
  final Map<String, dynamic> playerData;
  PlayerDataLoadedRP(this.playerData);
}
class PlayersErrorRP extends PlayersStateRP {
  final String message;
  PlayersErrorRP(this.message);
}
