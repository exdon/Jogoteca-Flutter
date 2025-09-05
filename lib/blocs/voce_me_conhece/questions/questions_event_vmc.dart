abstract class QuestionsEventVMC {}
class LoadQuestionsVMC extends QuestionsEventVMC {}
class LoadAvailableQuestionsVMC extends QuestionsEventVMC {
  final String partidaId;
  final String playerId;

  LoadAvailableQuestionsVMC({
    required this.partidaId,
    required this.playerId,
  });
}