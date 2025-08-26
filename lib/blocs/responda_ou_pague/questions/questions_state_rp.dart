abstract class QuestionsStateRP {}
class QuestionInitialRP extends QuestionsStateRP {}
class QuestionLoadingRP extends QuestionsStateRP {}
class QuestionLoadedRP extends QuestionsStateRP {
  final Map<String, dynamic> question;
  QuestionLoadedRP(this.question);
}
class QuestionErrorRP extends QuestionsStateRP {
  final String message;
  QuestionErrorRP(this.message);
}