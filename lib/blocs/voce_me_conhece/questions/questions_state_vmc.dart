abstract class QuestionsStateVMC {}
class QuestionsInitialVMC extends QuestionsStateVMC {}
class QuestionsLoadingVMC extends QuestionsStateVMC {}
class QuestionsLoadedVMC extends QuestionsStateVMC {
  final List<Map<String, dynamic>> questions;
  QuestionsLoadedVMC(this.questions);
}
class QuestionsErrorVMC extends QuestionsStateVMC {
  final String message;
  QuestionsErrorVMC(this.message);
}