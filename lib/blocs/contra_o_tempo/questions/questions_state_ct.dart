abstract class QuestionsStateCT {}
class QuestionsInitialCT extends QuestionsStateCT {}
class QuestionsLoadingCT extends QuestionsStateCT {}
class QuestionsLoadedCT extends QuestionsStateCT {
  final List<Map<String, dynamic>> questions;
  QuestionsLoadedCT(this.questions);
}
class QuestionsErrorCT extends QuestionsStateCT {
  final String message;
  QuestionsErrorCT(this.message);
}