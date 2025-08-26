abstract class QuestionsEventRP {}
class LoadQuestionRP extends QuestionsEventRP {
  String classificacao;
  LoadQuestionRP(this.classificacao);
}
class ResetQuestionRP extends QuestionsEventRP {}