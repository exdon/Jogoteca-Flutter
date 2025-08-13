abstract class QuestionsState {}
class QuestionsInitial extends QuestionsState {}
class QuestionsLoading extends QuestionsState {}
class QuestionsLoaded extends QuestionsState {
  final List<Map<String, dynamic>> questions;
  QuestionsLoaded(this.questions);
}
class QuestionsError extends QuestionsState {
  final String message;
  QuestionsError(this.message);
}