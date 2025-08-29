abstract class QuestionsStatePA {}
class QuestionsInitialPA extends QuestionsStatePA {}
class QuestionsLoadingPA extends QuestionsStatePA {}
class QuestionsLoadedPA extends QuestionsStatePA {
  final List<Map<String, dynamic>> questions;
  QuestionsLoadedPA(this.questions);
}
class QuestionsErrorPA extends QuestionsStatePA {
  final String message;
  QuestionsErrorPA(this.message);
}