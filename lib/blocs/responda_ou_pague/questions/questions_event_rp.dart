abstract class QuestionsEventRP {}
class LoadQuestionRP extends QuestionsEventRP {
  String classificacao;
  final List<String> answeredQuestions;
  final List<String> recentQuestions;
  LoadQuestionRP(this.classificacao, [this.answeredQuestions = const [], this.recentQuestions = const []]);
}
class ResetQuestionRP extends QuestionsEventRP {}