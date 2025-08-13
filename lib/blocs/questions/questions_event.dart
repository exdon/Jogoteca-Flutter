abstract class QuestionsEvent {}
class LoadQuestions extends QuestionsEvent {}
class AddQuestion extends QuestionsEvent {
  final String pergunta;
  final String respostaChatgpt;
  AddQuestion(this.pergunta, this.respostaChatgpt);
}
class EditQuestion extends QuestionsEvent {
  final String id;
  final String pergunta;
  final String respostaChatgpt;
  EditQuestion(this.id, this.pergunta, this.respostaChatgpt);
}
class DeleteQuestion extends QuestionsEvent {
  final String id;
  DeleteQuestion(this.id);
}