abstract class PlayersEventVMC {}

class LoadPlayersVMC extends PlayersEventVMC {
  final String partidaId;
  LoadPlayersVMC(this.partidaId);
}

class AddPlayerVMC extends PlayersEventVMC {
  final String partidaId;
  final String nome;
  final int indice;
  AddPlayerVMC(this.partidaId, this.nome, this.indice);
}

class AddPlayerAnswerVMC extends PlayersEventVMC {
  final String partidaId;
  final String questionId;
  final String playerId;
  final String answer;
  AddPlayerAnswerVMC(this.partidaId, this.questionId, this.playerId, this.answer);
}

class LoadPlayerAnswerVMC extends PlayersEventVMC {
  final String partidaId;
  final String questionId;
  final String playerId;
  LoadPlayerAnswerVMC(this.partidaId, this.questionId, this.playerId);
}

class SavePlayerAnswerVMC extends PlayersEventVMC {
  final String partidaId;
  final String questionId;
  final String playerId;
  final String answer;
  final List<String> opcoesFalsas;
  final bool? isTrue;

  SavePlayerAnswerVMC({
    required this.partidaId,
    required this.questionId,
    required this.playerId,
    required this.answer,
    required this.opcoesFalsas,
    this.isTrue,
  });
}

class UpdatePlayerStatsVMC extends PlayersEventVMC {
  final String playerId;
  final bool isCorrect;

  UpdatePlayerStatsVMC({
    required this.playerId,
    required this.isCorrect,
  });
}

class ResetPlayerStatsVMC extends PlayersEventVMC {
  final String playerId;

  ResetPlayerStatsVMC({required this.playerId});
}

// Adicionar estes eventos que faltam:

class GetPlayerAnswerVMC extends PlayersEventVMC {
  final String partidaId;
  final String questionId;
  final String playerId;
  GetPlayerAnswerVMC(this.partidaId, this.questionId, this.playerId);
}

class SavePlayerVoteVMC extends PlayersEventVMC {
  final String partidaId;
  final String questionId;
  final String jogadorRespondentId;
  final String jogadorVotanteId;
  final String voto;
  final bool acertou;

  SavePlayerVoteVMC({
    required this.partidaId,
    required this.questionId,
    required this.jogadorRespondentId,
    required this.jogadorVotanteId,
    required this.voto,
    required this.acertou,
  });
}

class GetVotesForQuestionVMC extends PlayersEventVMC {
  final String partidaId;
  final String questionId;
  final String jogadorRespondentId;

  GetVotesForQuestionVMC({
    required this.partidaId,
    required this.questionId,
    required this.jogadorRespondentId,
  });
}

class ResetAllPlayersStatsVMC extends PlayersEventVMC {
  final String partidaId;
  ResetAllPlayersStatsVMC({required this.partidaId});
}

class GetPlayerRankingVMC extends PlayersEventVMC {
  final String partidaId;
  GetPlayerRankingVMC({required this.partidaId});
}

class ClearAnsweredQuestionsVMC extends PlayersEventVMC {
  final String partidaId;
  ClearAnsweredQuestionsVMC({required this.partidaId});
}

class ResetGameVMC extends PlayersEventVMC {
  final String partidaId;
  ResetGameVMC({required this.partidaId});
}

class ResetCompleteGameVMC extends PlayersEventVMC {
  final String partidaId;
  ResetCompleteGameVMC({required this.partidaId});
}