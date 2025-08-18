abstract class PlayersState {}
class PlayersInitial extends PlayersState {}
class PlayersLoading extends PlayersState {}
class PlayersLoaded extends PlayersState {
  final List<Map<String, dynamic>> players;
  PlayersLoaded(this.players);
}
class PlayersError extends PlayersState {
  final String message;
  PlayersError(this.message);
}
class PlayersLoadedWithMessages extends PlayersState {
  final List<Map<String, dynamic>> players;
  final List<Map<String, dynamic>> directMessages;

  PlayersLoadedWithMessages(this.players, this.directMessages);
}
class ResultsLoading extends PlayersState {}
class ResultsLoaded extends PlayersState {
  final List<Map<String, dynamic>> results;

  ResultsLoaded(this.results);
}
class PlayersLoadedWithMessagesAndSA extends PlayersState {
  final List<Map<String, dynamic>> players;
  final List<Map<String, dynamic>> directMessages;
  final List<Map<String, dynamic>> superAnonimoQuestions;

  PlayersLoadedWithMessagesAndSA(this.players, this.directMessages, this.superAnonimoQuestions);
}