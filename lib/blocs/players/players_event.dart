abstract class PlayersEvent {}

class LoadPlayers extends PlayersEvent {
  final String partidaId;
  LoadPlayers(this.partidaId);
}

class AddPlayer extends PlayersEvent {
  final String partidaId;
  final String nome;
  final int pin;
  final int indice;
  AddPlayer(this.partidaId, this.indice, this.nome, this.pin);
}

class AddPlayerData extends PlayersEvent {
  final String partidaId;
  final String jogadorId;
  final String pergunta;
  final String resposta;
  final bool superAnonimo;
  final String? perguntaSuperAnonimo;
  final String? respostaSuperAnonimo;

  AddPlayerData(
      this.partidaId,
      this.jogadorId,
      this.pergunta,
      this.resposta,
      this.superAnonimo,
      this.perguntaSuperAnonimo,
      this.respostaSuperAnonimo
      );
}

class RemovePlayer extends PlayersEvent {
  final String partidaId;
  final String jogadorId;
  RemovePlayer(this.partidaId, this.jogadorId);
}

class LoadDirectMessages extends PlayersEvent {
  final String partidaId;
  final String jogadorId;

  LoadDirectMessages(this.partidaId, this.jogadorId);
}

class LoadResults extends PlayersEvent {
  final String partidaId;

  LoadResults(this.partidaId);
}

class SendDirectMessage extends PlayersEvent {
  final String partidaId;
  final String remetenteId;
  final String destinatarioId;
  final String mensagem;

  SendDirectMessage(this.partidaId, this.remetenteId, this.destinatarioId, this.mensagem);
}

class MarkMessageAsRead extends PlayersEvent {
  final String partidaId;
  final String jogadorId;
  final String messageId;

  MarkMessageAsRead(this.partidaId, this.jogadorId, this.messageId);
}

class MarkAllMessagesAsRead extends PlayersEvent {
  final String partidaId;
  final String jogadorId;

  MarkAllMessagesAsRead(this.partidaId, this.jogadorId);
}

class SendSuperAnonimoQuestion extends PlayersEvent {
  final String partidaId;
  final String remetenteId;
  final String destinatarioId;
  final String pergunta;

  SendSuperAnonimoQuestion(this.partidaId, this.remetenteId, this.destinatarioId, this.pergunta);
}

class LoadInbox extends PlayersEvent {
  final String partidaId;
  final String jogadorId;
  LoadInbox(this.partidaId, this.jogadorId);
}

class AnswerSuperAnonimoQuestion extends PlayersEvent {
  final String partidaId;
  final String jogadorId;
  final String questionId;
  final String resposta;

  AnswerSuperAnonimoQuestion(this.partidaId, this.jogadorId, this.questionId, this.resposta);
}