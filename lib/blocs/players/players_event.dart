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

  List<Object?> get props => [partidaId, remetenteId, destinatarioId, mensagem];
}

class MarkMessageAsRead extends PlayersEvent {
  final String partidaId;
  final String jogadorId;
  final String messageId;

  MarkMessageAsRead(this.partidaId, this.jogadorId, this.messageId);

  List<Object?> get props => [partidaId, jogadorId, messageId];
}

class MarkAllMessagesAsRead extends PlayersEvent {
  final String partidaId;
  final String jogadorId;

  MarkAllMessagesAsRead(this.partidaId, this.jogadorId);

  List<Object?> get props => [partidaId, jogadorId];
}