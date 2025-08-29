abstract class PlayersEventPA {}

class LoadPlayersPA extends PlayersEventPA {
  final String partidaId;
  LoadPlayersPA(this.partidaId);
}

class AddPlayerPA extends PlayersEventPA {
  final String partidaId;
  final String nome;
  final int pin;
  final int indice;
  AddPlayerPA(this.partidaId, this.indice, this.nome, this.pin);
}

class AddPlayerDataPA extends PlayersEventPA {
  final String partidaId;
  final String jogadorId;
  final String pergunta;
  final String resposta;
  final bool superAnonimo;
  final String? perguntaSuperAnonimo;
  final String? respostaSuperAnonimo;
  final String? detalhesSuperAnonimo;

  AddPlayerDataPA(
      this.partidaId,
      this.jogadorId,
      this.pergunta,
      this.resposta,
      this.superAnonimo,
      this.perguntaSuperAnonimo,
      this.respostaSuperAnonimo,
      this.detalhesSuperAnonimo
      );
}

class RemovePlayerPA extends PlayersEventPA {
  final String partidaId;
  final String jogadorId;
  RemovePlayerPA(this.partidaId, this.jogadorId);
}

class LoadDirectMessagesPA extends PlayersEventPA {
  final String partidaId;
  final String jogadorId;

  LoadDirectMessagesPA(this.partidaId, this.jogadorId);
}

class LoadResultsPA extends PlayersEventPA {
  final String partidaId;

  LoadResultsPA(this.partidaId);
}

class SendDirectMessagePA extends PlayersEventPA {
  final String partidaId;
  final String remetenteId;
  final String destinatarioId;
  final String mensagem;

  SendDirectMessagePA(this.partidaId, this.remetenteId, this.destinatarioId, this.mensagem);
}

class MarkMessageAsReadPA extends PlayersEventPA {
  final String partidaId;
  final String jogadorId;
  final String messageId;

  MarkMessageAsReadPA(this.partidaId, this.jogadorId, this.messageId);
}

class MarkAllMessagesAsReadPA extends PlayersEventPA {
  final String partidaId;
  final String jogadorId;

  MarkAllMessagesAsReadPA(this.partidaId, this.jogadorId);
}

class SendSuperAnonimoQuestionPA extends PlayersEventPA {
  final String partidaId;
  final String remetenteId;
  final String destinatarioId;
  final String pergunta;

  SendSuperAnonimoQuestionPA(this.partidaId, this.remetenteId, this.destinatarioId, this.pergunta);
}

class LoadInboxPA extends PlayersEventPA {
  final String partidaId;
  final String jogadorId;
  LoadInboxPA(this.partidaId, this.jogadorId);
}

class AnswerSuperAnonimoQuestionPA extends PlayersEventPA {
  final String partidaId;
  final String jogadorId;
  final String questionId;
  final String resposta;

  AnswerSuperAnonimoQuestionPA(this.partidaId, this.jogadorId, this.questionId, this.resposta);
}

class SendSuperAnonimoChallengePA extends PlayersEventPA {
  final String partidaId;
  final String remetenteId;
  final String destinatarioId;
  final String desafio;

  SendSuperAnonimoChallengePA(this.partidaId, this.remetenteId, this.destinatarioId, this.desafio);
}

class MarkChallengeAsCompletedPA extends PlayersEventPA {
  final String partidaId;
  final String jogadorId;
  final String challengeId;

  MarkChallengeAsCompletedPA(this.partidaId, this.jogadorId, this.challengeId);
}