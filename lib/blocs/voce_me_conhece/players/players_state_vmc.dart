abstract class PlayersStateVMC {}
class PlayersInitialVMC extends PlayersStateVMC {}
class PlayersLoadingVMC extends PlayersStateVMC {}
class PlayersLoadedVMC extends PlayersStateVMC {
  final List<Map<String, dynamic>> players;
  PlayersLoadedVMC(this.players);
}
class PlayersErrorVMC extends PlayersStateVMC {
  final String message;
  PlayersErrorVMC(this.message);
}
class PlayerAnswerLoadingVMC extends PlayersStateVMC {}
class PlayerAnswerLoadedVMC extends PlayersStateVMC {
  final List<Map<String, dynamic>> playerAnswer;
  PlayerAnswerLoadedVMC(this.playerAnswer);
}

class SinglePlayerAnswerLoadedVMC extends PlayersStateVMC {
  final Map<String, dynamic>? playerAnswer;
  SinglePlayerAnswerLoadedVMC(this.playerAnswer);
}

class PlayerAnswerSavedVMC extends PlayersStateVMC {}

class VotesLoadingVMC extends PlayersStateVMC {}

class VotesLoadedVMC extends PlayersStateVMC {
  final List<Map<String, dynamic>> votes;
  VotesLoadedVMC(this.votes);
}

class RankingLoadingVMC extends PlayersStateVMC {}

class RankingLoadedVMC extends PlayersStateVMC {
  final List<Map<String, dynamic>> ranking;
  RankingLoadedVMC(this.ranking);
}
